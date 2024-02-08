Rails.application.routes.draw do
  root to: redirect("/start")

  devise_for :users,
             module: :users,
             path_names: {
               sign_in: "sign-in",
               sign_out: "sign-out"
             }
  get "sign-in", to: redirect("/users/sign_in")

  constraints -> { !Rails.env.production? } do
    mount Avo::Engine, at: Avo.configuration.root_path
    mount GoodJob::Engine => "/good-job"
    mount Flipper::UI.app => "/flipper"
  end

  get "/start", to: "pages#start"
  get "/dashboard", to: "dashboard#index"
  get "/accessibility-statement",
      to: "content#accessibility_statement",
      as: :accessibility_statement
  get "/privacy-policy", to: "content#privacy_policy", as: :privacy_policy

  get "/ping" => proc { [200, {}, ["PONG"]] }

  if Rails.env.development? || Rails.env.test?
    get "/reset", to: "dev#reset"
    get "/random_consent_form", to: "dev#random_consent_form"
  end

  get "/csrf", to: "csrf#new"

  resource :pilot, only: [] do
    get "/", to: "pilot#manage", as: :manage
    get "/manual", to: "pilot#manual", as: :manual

    resources :registrations, only: %i[] do
      get "/", to: "pilot#registrations", on: :collection
      get "/download", to: "pilot#download", on: :collection
    end

    resource :cohort_list, as: :cohort, only: %i[new create] do
      get "success", on: :collection
    end
  end

  resources :sessions, only: %i[create index show update] do
    get "consents", to: "consents#index", on: :member
    get "triage", to: "triage#index", on: :member
    get "vaccinations", to: "vaccinations#index", on: :member

    resources :edit_sessions, only: %i[show update], path: "edit", as: :edit

    constraints -> { Flipper.enabled?(:make_session_in_progress_button) } do
      put "make-in-progress", to: "sessions#make_in_progress", on: :member
    end

    namespace :parent_interface, path: "/" do
      resources :consent_forms, path: :consents, only: [:create] do
        get "start", on: :collection
        get "cannot-consent"
        get "confirm"
        put "record"

        resources :edit, only: %i[show update], controller: "consent_forms/edit"
      end
    end

    resources :patients, only: [] do
      get "/:route",
          action: :show,
          on: :member,
          as: "",
          controller: "patient_sessions",
          route: /consents|triage|vaccinations/

      resource :triage, only: %i[create update]

      resource :vaccinations, only: %i[new create update] do
        get "history", on: :member

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

      post ":route/consents", to: "manage_consents#create", as: :manage_consents
      resources :manage_consents,
                only: %i[show update],
                path: ":route/consents/:consent_id/"
    end

    constraints -> { Flipper.enabled? :offline_working } do
      get "setup-offline", to: "offline_passwords#new", on: :member
      post "setup-offline", to: "offline_passwords#create", on: :member
    end
  end

  resources :schools, only: [:show] do
    get "close_registration", on: :member
    post "close_registration",
         to: "schools#handle_close_registration",
         on: :member
  end
  resources :consent_forms, only: [:show]

  resource :registration, path: ":school_id", only: %i[new create] do
    get "/", to: "registrations#new"
    get "confirmation", on: :collection
    get ":slug", to: "registrations#slug"
  end

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
