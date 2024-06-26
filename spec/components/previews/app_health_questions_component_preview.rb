# frozen_string_literal: true

class AppHealthQuestionsComponentPreview < ViewComponent::Preview
  def single_consent_triage_not_needed
    setup

    patient_session =
      FactoryBot.create(
        :patient_session,
        :consent_given_triage_not_needed,
        session:
      )

    render AppHealthQuestionsComponent.new(consents: patient_session.consents)
  end

  def single_consent_triage_needed
    setup

    patient_session =
      FactoryBot.create(
        :patient_session,
        :consent_given_triage_needed,
        session:
      )

    render AppHealthQuestionsComponent.new(consents: patient_session.consents)
  end

  def multiple_consents_no_triage_needed
    setup

    patient_session =
      FactoryBot.create(
        :patient_session,
        :consent_given_triage_not_needed,
        session:
      )
    FactoryBot.create(
      :consent,
      :given,
      :no_contraindications,
      patient: patient_session.patient,
      campaign:
    )

    render AppHealthQuestionsComponent.new(consents: patient_session.consents)
  end

  def multiple_consents_triage_needed
    setup

    patient_session =
      FactoryBot.create(
        :patient_session,
        :consent_given_triage_needed,
        session:
      )
    patient_session.consents.first.update!(parent_relationship: :mother)

    dad_consent =
      FactoryBot.create(
        :consent,
        :given,
        :health_question_notes,
        :from_dad,
        patient: patient_session.patient,
        campaign:
      )

    dad_consent.health_answers.first.notes = "They fainted once"
    dad_consent.save!

    render AppHealthQuestionsComponent.new(
             consents: patient_session.consents.reload
           )
  end

  private

  attr_reader :campaign, :session

  def setup
    @campaign =
      FactoryBot.create(
        :campaign,
        :hpv,
        team: Team.first || FactoryBot.create(:team)
      )
    @session = FactoryBot.create(:session, patients_in_session: 0, campaign:)
  end
end
