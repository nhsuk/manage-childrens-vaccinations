require "rails_helper"

RSpec.describe AppTriageFormComponent, type: :component do
  describe "#initialize" do
    let(:patient_session) { create :patient_session }
    let(:triage) { nil }
    let(:url) { nil }
    let(:component) { described_class.new(patient_session:, triage:, url:) }

    subject { component }

    it { should be_a described_class }

    describe "triage instance variable" do
      subject { component.instance_variable_get(:@triage) }

      context "patient_session has no existing triage" do
        it "creates a new Triage object" do
          should be_a Triage
        end
      end

      context "patient_session has existing triage" do
        let(:old_triage) { create :triage, :kept_in_triage }
        let(:patient_session) { create :patient_session, triage: [old_triage] }

        it { should_not eq triage }
        it { should be_needs_follow_up } # AKA kept_in_triage
      end
    end
  end
end
