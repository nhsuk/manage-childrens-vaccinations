Rails.application.routes.draw do
  root to: redirect("/start")

  mount Avo::Engine, at: Avo.configuration.root_path

  get "/start", to: "pages#start"
  get "/dashboard", to: "dashboard#index"

  get "/ping" => proc { [200, {}, ["PONG"]] }
  get "/sha" => proc { [200, {}, [Rails.application.config.commit_sha]] }

  get "/reset", to: "dev#reset" if Rails.env.development? || Rails.env.test?

  get "/csrf", to: "csrf#new"

  resources :sessions, only: %i[index show] do
    get "triage", to: "triage#index", on: :member
    get "vaccinations", to: "vaccinations#index", on: :member

    resources :patients do
      resource :triage, only: %i[show create update]
      resource :vaccinations, only: %i[create show update] do
        get "history", on: :member

        resource "batch", only: %i[edit update], controller: "vaccinations/batches"
        resource "delivery_site", only: %i[edit update], controller: "vaccinations/delivery_site"
        get "edit/reason", action: "edit_reason", on: :member
        get "confirm", on: :member
        put "record", on: :member

        post "consent", on: :member

        get "show-template", on: :collection
        get "record-template", on: :collection
      end

      resource :consent_responses, path: "consent" do
        get "assessing-gillick", to: "consent_responses#assessing_gillick"

        get "edit/gillick", to: "consent_responses#edit_gillick"
        put "update/gillick", to: "consent_responses#update_gillick"

        get "edit/who", to: "consent_responses#edit_who"
        get "edit/agree", to: "consent_responses#edit_consent"
        get "edit/reason", to: "consent_responses#edit_reason"
        get "edit/questions", to: "consent_responses#edit_questions"
        get "edit/confirm", to: "consent_responses#edit_confirm"

        put "record"
      end
    end

    get "setup-offline", to: "offline_passwords#new", on: :member
    post "setup-offline", to: "offline_passwords#create", on: :member
  end

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
