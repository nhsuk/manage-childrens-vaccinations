require "rails_helper"

RSpec.describe CohortList, type: :model do
  subject(:cohort_list) { described_class.new(csv:, team:) }

  let(:team) { create(:team, locations: [location]) }
  # Ensure we have a location with id=1 since our fixture file uses it
  let!(:location) { Location.find_by(id: 1) || create(:location, id: 1) }
  let(:csv) { fixture_file_upload("spec/fixtures/cohort_list/#{file}") }

  before do
    if Registration.count.zero?
      create(:registration, id: 1, location_id: 1)
      create(:registration, id: 2, location_id: 1)
    end
  end

  # Clear out any patients created by the test suite to prevent
  # the validations from failing due to duplicate registration IDs
  before(:each) { Patient.where.not(registration: nil).delete_all }

  describe "#load_data!" do
    describe "with missing CSV" do
      let(:csv) { nil }

      it "is invalid" do
        cohort_list.load_data!

        expect(cohort_list).to be_invalid
        expect(cohort_list.errors[:csv]).to include(/Choose/)
      end
    end

    describe "with malformed CSV" do
      let(:file) { "malformed.csv" }

      it "is invalid" do
        cohort_list.load_data!

        expect(cohort_list).to be_invalid
        expect(cohort_list.errors[:csv]).to include(/correct format/)
      end
    end

    describe "with too many rows" do
      let(:file) { "too_many_rows.csv" }

      it "is invalid" do
        cohort_list.load_data!

        expect(cohort_list).to be_invalid
        expect(cohort_list.errors[:csv]).to include(/fewer rows/)
      end
    end
  end

  describe "#parse_rows!" do
    describe "with invalid headers" do
      let(:file) { "invalid_headers.csv" }

      it "populates header errors" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_invalid
        expect(cohort_list.errors[:csv]).to include(/missing.*headers/)
      end
    end

    describe "with invalid fields" do
      let(:file) { "invalid_fields.csv" }

      it "populates rows" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_invalid
        expect(cohort_list.rows).not_to be_empty
      end
    end

    describe "with unrecognised fields" do
      let(:file) { "valid_cohort_extra_fields.csv" }

      it "populates rows" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_valid
      end
    end

    describe "with valid fields" do
      let(:file) { "valid_cohort.csv" }

      it "is valid" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_valid
      end

      it "accepts NHS numbers with spaces, removes spaces" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_valid
        expect(cohort_list.rows.second.to_patient[:nhs_number]).to eq(
          "1234567891"
        )
      end

      it "parses dates in the ISO8601 format" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_valid
        expect(cohort_list.rows.first.to_patient[:date_of_birth]).to eq(
          Date.new(2010, 1, 1)
        )
      end

      it "parses dates in the DD/MM/YYYY format" do
        cohort_list.load_data!
        cohort_list.parse_rows!

        expect(cohort_list).to be_valid
        expect(cohort_list.rows.second.to_patient[:date_of_birth]).to eq(
          Date.new(2010, 1, 2)
        )
      end
    end
  end

  describe "#generate_patients!" do
    let(:file) { "valid_cohort.csv" }

    it "creates patients" do
      cohort_list.load_data!
      cohort_list.parse_rows!

      expect { cohort_list.generate_patients! }.to change { Patient.count }.by(
        2
      )
    end
  end

  describe ".from_registrations" do
    let(:registration) { build(:registration) }

    it "creates a CohortList" do
      cohort_list = described_class.from_registrations([registration])

      expect(cohort_list).to be_a(described_class)
      expect(cohort_list.data).to be_a(Array)
      expect(row = cohort_list.data.first).to be_a(Array)
      expect(row.first).to eq(registration.created_at)
    end
  end

  describe "#to_csv" do
    let(:registration) { build(:registration) }

    it "returns a CSV" do
      cohort_list = described_class.from_registrations([registration])

      expect(cohort_list.to_csv).to be_a(String)
      expect(cohort_list.to_csv).to include(registration.created_at.to_s)
    end
  end
end
