# frozen_string_literal: true

class AppPatientPageComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :patient_session

  def initialize(patient_session:, route:, vaccination_record: nil)
    super

    @patient_session = patient_session
    @vaccination_record = vaccination_record || VaccinationRecord.new
    @route = route
  end

  delegate :patient, to: :patient_session
  delegate :session, to: :patient_session
end
