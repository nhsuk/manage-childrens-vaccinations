Rails.application.routes.draw do
  devise_for :users,
             module: :users,
             path_names: {
               sign_in: "sign-in",
               sign_out: "sign-out"
             },
             controllers: {
               omniauth_callbacks: "users/omniauth_callbacks"
             }
  get(
    "/users/auth/openid_connect/callback",
    to: redirect { |p, r| "/users/auth/cis2/callback?#{r.paramsp.to_query}" }
  )
  get "sign-in", to: redirect("/users/sign_in")

  root to: redirect("/start")

  mount GoodJob::Engine => "/good-job"

  get "/start", to: "pages#start"
  get "/dashboard", to: "dashboard#index"
  get "/accessibility-statement",
      to: "content#accessibility_statement",
      as: :accessibility_statement
  get "/privacy-policy", to: "content#privacy_policy", as: :privacy_policy

  get "/ping" => proc { [200, {}, ["PONG"]] }

  flipper_app =
    Flipper::UI.app do |builder|
      builder.use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(
          Settings.support_username,
          username
        ) &&
          ActiveSupport::SecurityUtils.secure_compare(
            Settings.support_password,
            password
          )
      end
    end
  mount flipper_app, at: "/flipper"

  if Rails.env.development? || Rails.env.test?
    get "/reset", to: "dev#reset"
    get "/random_consent_form", to: "dev#random_consent_form"
  end

  get "/csrf", to: "csrf#new"

  resource :pilot, only: [] do
    get "/", to: "pilot#manage", as: :manage

    resource :cohort_list, as: :cohort, only: %i[new create] do
      get "success", on: :collection
    end
  end

  resources :campaigns, only: %i[index show]

  resources :sessions, only: %i[create edit index show update] do
    namespace :parent_interface, path: "/" do
      resources :consent_forms, path: :consents, only: [:create] do
        get "start", on: :collection
        get "cannot-consent-school"
        get "cannot-consent-responsibility"
        get "deadline-passed", on: :collection
        get "confirm"
        put "record"

        resources :edit, only: %i[show update], controller: "consent_forms/edit"
      end
    end

    resources :edit_sessions, only: %i[show update], path: "edit", as: :edit

    constraints -> { Flipper.enabled?(:make_session_in_progress_button) } do
      put "make-in-progress", to: "sessions#make_in_progress", on: :member
    end

    resources :patients, only: [] do
      get "/:route",
          action: :show,
          on: :member,
          controller: "patient_sessions",
          route: /consents|triage|vaccinations/
    end

    constraints -> { Flipper.enabled? :offline_working } do
      get "setup-offline", to: "offline_passwords#new", on: :member
      post "setup-offline", to: "offline_passwords#create", on: :member
    end
  end

  scope "/sessions/:session_id/:section", as: "session" do
    constraints section: "consents" do
      defaults section: "consents" do
        get "/",
            as: "consents",
            to:
              redirect(
                "/sessions/%{session_id}/consents/#{TAB_PATHS[:consents].keys.first}"
              )

        get "unmatched-responses",
            to: "consent_forms#unmatched_responses",
            as: :consents_unmatched_responses

        get ":tab",
            controller: "consents",
            action: :index,
            as: :consents_tab,
            tab: TAB_PATHS[:consents].keys.join("|")
      end
    end

    constraints section: "triage" do
      defaults section: "triage" do
        get "/",
            as: "triage",
            to:
              redirect(
                "/sessions/%{session_id}/triage/#{TAB_PATHS[:triage].keys.first}"
              )

        get ":tab",
            controller: "triage",
            action: :index,
            as: :triage_tab,
            tab: TAB_PATHS[:triage].keys.join("|")
      end
    end

    constraints section: "vaccinations" do
      defaults section: "vaccinations" do
        get "/",
            as: "vaccinations",
            to:
              redirect(
                "/sessions/%{session_id}/vaccinations/#{TAB_PATHS[:vaccinations].keys.first}"
              )

        get ":tab",
            controller: "vaccinations",
            action: :index,
            as: :vaccinations_tab,
            tab: TAB_PATHS[:vaccinations].keys.join("|")
      end
    end

    scope ":tab" do
      resources :patients, only: %i[show] do
        get "log"

        post "consents", to: "manage_consents#create", as: :manage_consents
        resources :manage_consents,
                  only: %i[show update],
                  path: "consents/:consent_id/" do
          get "details", on: :collection, to: "consents#show"
        end

        resource :gillick_assessment, only: %i[new create]

        resource :gillick_assessment,
                 path: "gillick-assessment/:id",
                 only: %i[show update]

        resource :triage, only: %i[new create]

        resource :vaccinations, only: %i[new create update] do
          resource "batch",
                   only: %i[edit update],
                   controller: "vaccinations/batches"
          resource "delivery_site",
                   only: %i[edit update],
                   controller: "vaccinations/delivery_site"
          get "edit/reason", action: "edit_reason", on: :member
          get "confirm", on: :member
          put "record", on: :member

          post "handle-consent", on: :member

          get "show-template", on: :collection
          get "record-template", on: :collection
        end
      end
    end

    # These are just used to create helpers with better names that allow passing
    # in section and/or tab as a parameter. e.g. session_section_path(@session,
    # section: @section) which looks cleaner than session_triage_path(@session,
    # section: @section)
    get "/", to: "errors#not_found", as: "section"
    get "/:tab", to: "errors#not_found", as: "section_tab"
  end

  resources :vaccines, only: %i[index show] do
    resources :batches, only: %i[create edit new update] do
      post "make-default", on: :member, as: :make_default
      post "remove-default", on: :member, as: :remove_default
    end
  end

  resources :reports, only: %i[index show]

  resources :consent_forms, path: "consent-forms", only: [:show] do
    get "match/:patient_session_id",
        on: :member,
        to: "consent_forms#review_match",
        as: :review_match
    post "match/:patient_session_id",
         on: :member,
         to: "consent_forms#match",
         as: :match
  end

  namespace :users do
    resources :accounts, only: %i[show update]
  end

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
