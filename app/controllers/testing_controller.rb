require "faker"

class TestingController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :ensure_dev_or_test_env

  layout "two_thirds"

  skip_before_action :verify_authenticity_token

  def show_campaign
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      format.json do
        render json: {
                 registrationPage:
                   new_school_registration_path(
                     @campaign.sessions.first.location
                   ),
                 locationName: @campaign.sessions.first.location.name
               }
      end
    end
  end

  def generate_campaign
    Faker::Config.locale = "en-GB"

    session = FactoryBot.create(:session)
    location =
      FactoryBot.create(
        :location,
        name: "Testing Location",
        sessions: [session],
        **location_params
      )
    campaign = location.sessions.first.campaign
    redirect_to testing_show_campaign_path(id: campaign.id)
  end

  private

  def location_params
    params.require(:location).permit(
      :name,
      :address,
      :postcode,
      :latitude,
      :longitude,
      :permission_to_observe_required,
      :registration_open
    )
  end

  def ensure_dev_or_test_env
    unless Rails.env.development? || Rails.env.test?
      raise "Not in test environment"
    end
  end
end
