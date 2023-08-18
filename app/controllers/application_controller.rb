class ApplicationController < ActionController::Base
  before_action :set_disable_cache_headers

  class UnprocessableEntity < StandardError
  end

  unless Rails.configuration.consider_all_requests_local
    rescue_from UnprocessableEntity, with: :handle_unprocessable_entity
  end

  if Rails.env.staging? || Rails.env.production?
    http_basic_authenticate_with name: Settings.support_username,
                                 password: Settings.support_password,
                                 message:
                                   "THIS IS NOT A PRODUCTION NHS.UK SERVICE"
  end

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  private

  def set_disable_cache_headers
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

  def handle_unprocessable_entity(_exception)
    render "errors/unprocessable_entity", status: :unprocessable_entity
  end
end
