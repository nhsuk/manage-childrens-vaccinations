# == Schema Information
#
# Table name: patient_sessions
#
#  id                                  :bigint           not null, primary key
#  gillick_competence_notes            :text
#  gillick_competent                   :boolean
#  state                               :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  gillick_competence_assessor_user_id :bigint
#  patient_id                          :bigint           not null
#  session_id                          :bigint           not null
#
# Indexes
#
#  index_patient_sessions_on_gillick_competence_assessor_user_id  (gillick_competence_assessor_user_id)
#  index_patient_sessions_on_patient_id_and_session_id            (patient_id,session_id) UNIQUE
#  index_patient_sessions_on_session_id_and_patient_id            (session_id,patient_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (gillick_competence_assessor_user_id => users.id)
#
require "rails_helper"

RSpec.describe PatientSession do
  describe "#vaccine_record" do
    it "returns the last non-draft vaccination record" do
      patient_session = create(:patient_session)
      vaccination_record = create(:vaccination_record, patient_session:)
      vaccination_record.update!(recorded_at: 1.day.ago)
      draft_vaccination_record = create(:vaccination_record, patient_session:)
      draft_vaccination_record.update!(recorded_at: nil)

      expect(patient_session.vaccination_record).to eq vaccination_record
    end
  end

  describe "#latest_consents" do
    let(:campaign) { create(:campaign) }
    let(:patient_session) { create(:patient_session, patient:, campaign:) }

    subject { patient_session.latest_consents }

    context "multiple consent given responses from different parents" do
      let(:consent_1) { build(:consent, campaign:, response: :given) }
      let(:consent_2) { build(:consent, campaign:, response: :given) }
      let(:patient) { create(:patient, consents: [consent_1, consent_2]) }

      it "groups consents by parent name" do
        is_expected.to eq [consent_1, consent_2]
      end
    end

    context "multiple consent responses from same parents" do
      let(:parent_name) { Faker::Name.name }
      let(:consent_1) do
        build :consent, campaign:, parent_name:, response: :refused
      end
      let(:consent_2) do
        build :consent, campaign:, parent_name:, response: :given
      end
      let(:patient) { create(:patient, consents: [consent_1, consent_2]) }

      it "returns the latest consent for each parent" do
        is_expected.to eq [consent_2]
      end
    end

    context "multiple consent responses from same parent where one is draft" do
      let(:parent_name) { Faker::Name.name }
      let(:consent_1) do
        build :consent,
              campaign:,
              parent_name:,
              recorded_at: 1.day.ago,
              response: :refused
      end
      let(:consent_2) do
        build :consent,
              campaign:,
              parent_name:,
              recorded_at: nil,
              response: :given
      end
      let(:patient) { create(:patient, consents: [consent_1, consent_2]) }

      it "does not return a draft consent record" do
        is_expected.to eq [consent_1]
      end
    end
  end
end
