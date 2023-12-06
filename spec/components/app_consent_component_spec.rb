require "rails_helper"

RSpec.describe AppConsentComponent, type: :component do
  before { rendered_component }

  subject { page }

  let(:component) { described_class.new(patient_session:, route:) }
  let(:rendered_component) { render_inline(component) }

  let(:consent) { patient_session.consents.first }
  let(:route) { "triage" }
  let(:relation) { consent.human_enum_name(:parent_relationship).capitalize }

  context "consent is not present" do
    let(:patient_session) { create(:patient_session) }

    it { should_not have_css("p.app-status", text: "Consent (given|refused)") }
    it { should_not have_css("details", text: /Consent (given|refused) by/) }
    it { should_not have_css("details", text: "Responses to health questions") }
    it { should have_css("p", text: "No response yet") }
    it { should have_css("a", text: "Get consent") }
    it { should have_css("a", text: "Assess Gillick competence") }
  end

  context "consent is refused" do
    let(:patient_session) { create(:patient_session, :consent_refused) }

    it { should have_css("p.app-status", text: "Consent refused") }

    let(:summary) { "Consent refused by #{consent.parent_name} (#{relation})" }
    it { should have_css("details[open]", text: summary) }

    it { should have_css("a", text: "Contact parent or guardian") }
    it { should_not have_css("details", text: "Responses to health questions") }
  end

  context "consent is given needing triage" do
    let(:patient_session) do
      create(:patient_session, :consent_given_triage_needed)
    end

    it { should have_css("p.app-status", text: "Consent given") }

    let(:summary) { "Consent given by #{consent.parent_name} (#{relation})" }
    it { should have_css("details[open]", text: summary) }

    it { should_not have_css("a", text: "Contact parent or guardian") }
    it { should have_css("details", text: "Responses to health questions") }

    it "opens the health questions details" do
      should have_css("details[open]", text: "Responses to health questions")
    end
  end

  context "consent is given not needing triage" do
    let(:patient_session) do
      create(:patient_session, :consent_given_triage_not_needed)
    end

    let(:summary) { "Consent given by #{consent.parent_name} (#{relation})" }
    it { should have_css("details[open]", text: summary) }

    it { should_not have_css("a", text: "Contact parent or guardian") }
    it { should have_css("details", text: "Responses to health questions") }

    it "does not open the health questions details" do
      should have_css "details:not([open])",
                      text: "Responses to health questions"
    end
  end

  context "consent given, triaged and ready to be vaccinated" do
    let(:patient_session) do
      create(:patient_session, :triaged_ready_to_vaccinate)
    end

    let(:summary) { "Consent given by #{consent.parent_name} (#{relation})" }
    it { should have_css("details[open]", text: summary) }

    it "does not open the health questions details" do
      should have_css "details:not([open])",
                      text: "Responses to health questions"
    end
  end

  context "consent given needing triage and patient has been vaccinated" do
    let(:patient_session) { create(:patient_session, :vaccinated) }

    let(:summary) { "Consent given by #{consent.parent_name} (#{relation})" }
    it { should have_css("details:not([open])", text: summary) }

    it "does not open the health questions details" do
      should have_css "details:not([open])",
                      text: "Responses to health questions"
    end
  end

  context "consent given needing triage and patient cannot be vaccinated" do
    let(:patient_session) do
      create(:patient_session, :triaged_do_not_vaccinate)
    end

    let(:summary) { "Consent given by #{consent.parent_name} (#{relation})" }
    it { should have_css("details:not([open])", text: summary) }

    it "does not open the health questions details" do
      should have_css "details:not([open])",
                      text: "Responses to health questions"
    end
  end
end
