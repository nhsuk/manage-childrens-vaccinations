# frozen_string_literal: true

class AppConsentCardComponent < ViewComponent::Base
  def initialize(consent:)
    super

    @consent = consent
  end

  def heading
    by =
      {
        given: "Consent given by",
        refused: "Refusal confirmed by",
        not_provided: "Contacted"
      }[
        @consent.response.to_sym
      ]
    heading = "#{by} #{@consent.name}"
    heading += " (#{@consent.who_responded})" unless @consent.via_self_consent?
    heading
  end

  def call
    render AppCardComponent.new(heading:) do
      render AppConsentSummaryComponent.new(
               name: @consent.parent_name,
               relationship: @consent.who_responded,
               contact: {
                 phone: @consent.parent_phone,
                 email: @consent.parent_email
               },
               response: {
                 text:
                   @consent.summary_with_route(previous_response: "refused"),
                 timestamp: @consent.recorded_at,
                 recorded_by: @consent.recorded_by
               },
               refusal_reason: {
                 reason: @consent.human_enum_name(:reason_for_refusal),
                 notes: @consent.reason_for_refusal_notes
               }
             )
    end
  end
end
