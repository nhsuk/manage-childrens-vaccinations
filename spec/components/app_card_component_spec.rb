require "rails_helper"

RSpec.describe AppCardComponent, type: :component do
  let(:heading) { "A Heading" }
  let(:body) { "A Body" }
  let(:component) { described_class.new(heading:) }

  subject { page }

  before { render_inline(component) { body } }

  it { should have_css(".nhsuk-card") }
  it { should have_css("h2.nhsuk-card__heading", text: "A Heading") }
  it { should have_css(".nhsuk-card__content", text: "A Body") }

  context "no content is provided" do
    let(:body) { nil }

    it { should_not have_css(".nhsuk-card__content") }
  end

  context "feature card" do
    let(:component) { described_class.new(heading:, feature: true) }

    describe "card_classes" do
      subject { component.send(:card_classes) }

      it { should include "nhsuk-card--feature" }
    end

    describe "content_classes" do
      subject { component.send(:content_classes) }

      it { should include "nhsuk-card__content--feature" }
    end

    describe "heading_classes" do
      subject { component.send(:heading_classes) }

      it { should include "nhsuk-card__heading--feature" }
    end
  end

  context "coloured card" do
    let(:component) { described_class.new(heading:, colour: "purple") }

    describe "card_classes" do
      subject { component.send(:card_classes) }

      it { should include "nhsuk-card--purple" }
    end
  end
end
