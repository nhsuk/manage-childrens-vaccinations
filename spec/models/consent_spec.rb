# == Schema Information
#
# Table name: consents
#
#  id                          :bigint           not null, primary key
#  health_answers              :jsonb
#  parent_contact_method       :integer
#  parent_contact_method_other :text
#  parent_email                :text
#  parent_name                 :text
#  parent_phone                :text
#  parent_relationship         :integer
#  parent_relationship_other   :text
#  reason_for_refusal          :integer
#  reason_for_refusal_notes    :text
#  recorded_at                 :datetime
#  response                    :integer
#  route                       :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  campaign_id                 :bigint           not null
#  patient_id                  :bigint           not null
#  recorded_by_user_id         :bigint
#
# Indexes
#
#  index_consents_on_campaign_id          (campaign_id)
#  index_consents_on_patient_id           (patient_id)
#  index_consents_on_recorded_by_user_id  (recorded_by_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (recorded_by_user_id => users.id)
#
require "rails_helper"

RSpec.describe Consent do
  describe "when consent given by parent or guardian, all health questions are no" do
    it "does not require triage" do
      response = build(:consent_given, parent_relationship: :mother)

      expect(response).not_to be_triage_needed
    end
  end

  describe "when consent given by parent or guardian, but some info provided in the health questions" do
    it "does require triage" do
      health_answers = [
        HealthAnswer.new(
          question:
            "Does the child have a disease or treatment that severely affects their immune system?",
          response: "yes"
        )
      ]
      response =
        build(:consent_given, parent_relationship: :mother, health_answers:)

      expect(response).to be_triage_needed
    end

    it "returns notes need triage" do
      response = build(:consent_given, :health_question_notes)

      expect(response.reasons_triage_needed).to eq(
        ["Health questions need triage"]
      )
    end
  end

  describe "#from_consent_form!" do
    describe "the created consent object" do
      let(:session) { create(:session) }
      let(:consent_form) do
        create(:consent_form, session:, contact_method: :voice)
      end
      let(:patient_session) { create(:patient_session, session:) }

      subject(:consent) do
        Consent.from_consent_form!(consent_form, patient_session)
      end

      it "copies over attributes from consent_form" do
        expect(consent.reload).to(
          have_attributes(
            campaign: session.campaign,
            patient: patient_session.patient,
            consent_form:,
            parent_contact_method: consent_form.contact_method,
            parent_contact_method_other: consent_form.contact_method_other,
            parent_email: consent_form.parent_email,
            parent_name: consent_form.parent_name,
            parent_phone: consent_form.parent_phone,
            parent_relationship: consent_form.parent_relationship,
            parent_relationship_other: consent_form.parent_relationship_other,
            reason_for_refusal: consent_form.reason,
            reason_for_refusal_notes: consent_form.reason_notes,
            response: consent_form.response,
            route: "website"
          )
        )
      end

      it "copies health answers from consent_form" do
        expect(consent.reload.health_answers.to_json).to eq(
          consent_form.health_answers.to_json
        )
      end

      it "runs the do_consent state transition" do
        expect { consent }.to change(patient_session, :state).from(
          "added_to_session"
        ).to("consent_given_triage_not_needed")
      end
    end
  end

  describe "#summary_with_route" do
    it "summarises a given consent record (self-consent)" do
      expect(
        build(:consent_given, route: "self_consent").summary_with_route
      ).to eq("Consent given (self consent)")
    end

    it "summarises a refused consent record (phone)" do
      expect(build(:consent_refused, route: "phone").summary_with_route).to eq(
        "Consent refused (phone)"
      )
    end

    it "summarises a record where the parent couldn't be reached" do
      expect(
        build(
          :consent,
          response: :not_provided,
          route: "phone"
        ).summary_with_route
      ).to eq("No response when contacted (phone)")
    end

    it "summarises a given consent that follows a refusal" do
      expect(
        build(:consent_given, route: "phone").summary_with_route(
          previous_response: "refused"
        )
      ).to eq("Consent updated to given (phone)")
    end

    it "summarises a confirmed refusal" do
      expect(
        build(:consent_refused, route: "phone").summary_with_route(
          previous_response: "refused"
        )
      ).to eq("Refusal confirmed (phone)")
    end
  end

  describe "#summary_with_consenter" do
    it "summarises a given consent record (self-consent)" do
      consent = build(:consent_given, parent_name: "John", route: :self_consent)
      consent.patient.update!(first_name: "Peter", last_name: "Parker")
      expect(consent.summary_with_consenter).to eq(
        "Consent given by Peter Parker"
      )
    end

    it "summarises a refused consent record" do
      expect(
        build(
          :consent_refused,
          :from_mum,
          parent_name: "Jane"
        ).summary_with_consenter
      ).to eq("Consent refused by Jane (Mum)")
    end

    it "summarises a record where the parent couldn't be reached" do
      expect(
        build(
          :consent,
          :from_dad,
          response: :not_provided,
          parent_name: "John"
        ).summary_with_consenter
      ).to eq("Contacted John (Dad)")
    end

    it "summarises a confirmed refusal" do
      expect(
        build(
          :consent_refused,
          :from_mum,
          parent_name: "Jane"
        ).summary_with_consenter(previous_response: "refused")
      ).to eq("Refusal confirmed by Jane (Mum)")
    end
  end

  describe "#recorded scope" do
    let(:patient) { create(:patient) }

    it "returns only consents that have been recorded" do
      consent = create(:consent, patient:, recorded_at: Time.zone.now)
      create(:consent, patient:, recorded_at: nil)

      expect(patient.consents.recorded).to eq([consent])
    end
  end

  describe "#recorded?" do
    it "returns true if recorded_at is set" do
      consent = build(:consent, recorded_at: Time.zone.now)

      expect(consent).to be_recorded
    end

    it "returns false if recorded_at is nil" do
      consent = build(:consent, recorded_at: nil)

      expect(consent).not_to be_recorded
    end
  end
end
