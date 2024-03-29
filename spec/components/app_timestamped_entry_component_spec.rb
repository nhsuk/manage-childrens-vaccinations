require "rails_helper"

RSpec.describe AppTimestampedEntryComponent, type: :component do
  subject { page }

  before { render_inline(component) }

  context "with text and a timestamp" do
    let(:component) do
      described_class.new(
        text: "Summary of a thing",
        timestamp: Time.zone.local(2024, 2, 17, 12, 23, 0)
      )
    end

    let(:consent) { create(:consent, :given) }
    let(:consents) { [consent] }

    it { should have_text("Summary of a thing") }
    it { should have_text("17 Feb 2024 at 12:23pm") }
  end

  context "with a user who recorded the entry" do
    let(:component) do
      described_class.new(
        text: "Summary of a thing",
        timestamp: Time.zone.local(2024, 2, 17, 12, 23, 0),
        recorded_by:
          create(:user, full_name: "Test User", email: "test@example.com")
      )
    end

    it { should have_link("Test User", href: "mailto:test@example.com") }
  end
end
