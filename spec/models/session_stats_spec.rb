require "rails_helper"

RSpec.describe SessionStats do
  describe "#call" do
    let(:session) { create :session }

    subject do
      described_class.new(
        patient_sessions: session.patient_sessions,
        location: session.location
      ).call
    end

    it "returns a hash of session stats" do
      expect(subject).to eq(
        with_consent_given: 0,
        with_consent_refused: 0,
        without_a_response: 0,
        needing_triage: 0,
        ready_to_vaccinate: 0,
        unmatched_responses: 0
      )
    end

    context "with patient sessions" do
      before do
        create(:patient_session, :consent_refused, session:) # consent refused
        create(:patient_session, :added_to_session, session:) # without a response
        create(:patient_session, :consent_given_triage_needed, session:) # needing triage, consent given
        create(:patient_session, :triaged_kept_in_triage, session:) # needing triage, consent given
        create(:patient_session, :triaged_ready_to_vaccinate, session:) # ready to vaccinate, consent given
        create(:patient_session, :consent_given_triage_not_needed, session:) # ready to vaccinate, consent given

        create(:consent_form, :recorded, session:, consent_id: nil) # => unmatched response
      end

      it "returns a hash of session stats" do
        expect(subject).to eq(
          with_consent_given: 4,
          with_consent_refused: 1,
          without_a_response: 1,
          needing_triage: 2,
          ready_to_vaccinate: 2,
          unmatched_responses: 1
        )
      end
    end
  end
end
