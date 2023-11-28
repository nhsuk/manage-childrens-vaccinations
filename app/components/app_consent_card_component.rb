class AppConsentCardComponent < ViewComponent::Base
  attr_reader :patient_session, :consent

  def initialize(patient_session:, consent:, route:)
    super

    @patient_session = patient_session
    @consent = consent
    @route = route
  end

  delegate :patient, to: :patient_session
  delegate :session, to: :patient_session

  def display_health_questions?
    @consent&.response_given?
  end
end
