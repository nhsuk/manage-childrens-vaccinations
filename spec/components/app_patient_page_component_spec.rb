require "rails_helper"

RSpec.describe AppPatientPageComponent, type: :component do
  let(:component) do
    described_class.new(patient_session:, route: "triage", triage: nil)
  end
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

    it { should have_css(".nhsuk-card__heading", text: "Child details") }
    it { should have_css(".nhsuk-card__heading", text: "Consent") }
    it { should_not have_css(".nhsuk-card__heading", text: "Triage notes") }
    it "shows the triage form" do
      should have_css(".nhsuk-card__heading", text: "Is it safe to vaccinate")
    end
    it "does not show the vaccination form" do
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

    it { should have_css(".nhsuk-card__heading", text: "Child details") }
    it { should have_css(".nhsuk-card__heading", text: "Consent") }
    it { should have_css(".nhsuk-card__heading", text: "Triage notes") }
    it "does not show the triage form" do
      should_not have_css(
                   ".nhsuk-card__heading",
                   text: "Is it safe to vaccinate"
                 )
    end
    it "shows the vaccination form" do
      should have_css(
               ".nhsuk-card__heading",
               text: "Did they get the HPV vaccine?"
             )
    end
  end
end
