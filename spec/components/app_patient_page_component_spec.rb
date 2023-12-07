require "rails_helper"

RSpec.describe AppPatientPageComponent, type: :component do
  let(:component) do
    described_class.new(patient_session:, route: "triage", triage:)
  end
  let(:triage) { nil }
  let!(:rendered) { render_inline(component) }

  subject { page }

  context "patient in triage" do
    let(:patient_session) do
      FactoryBot.create(
        :patient_session,
        :consent_given_triage_needed,
        :session_in_progress
      )
    end
    let(:triage) { FactoryBot.create(:triage, patient_session:) }

    it { should have_css(".nhsuk-card", text: "Child details") }
    it { should have_css(".nhsuk-card", text: "Consent") }
    it { should have_css(".nhsuk-card", text: "Triage notes") }
    it { should have_css(".nhsuk-card", text: "Triage") }
    it do
      should_not have_css(".nhsuk-card", text: "Did they get the HPV vaccine?")
    end
  end

  context "patient ready to vaccinate" do
    let(:patient_session) do
      FactoryBot.create(
        :patient_session,
        :triaged_ready_to_vaccinate,
        :session_in_progress
      )
    end

    it { should have_css(".nhsuk-card", text: "Child details") }
    it { should have_css(".nhsuk-card", text: "Consent") }
    it { should have_css(".nhsuk-card", text: "Triage notes") }
    it { should_not have_css(".nhsuk-card", text: /^Triage$/) }
    it { should have_css(".nhsuk-card", text: "Did they get the HPV vaccine?") }
  end
end
