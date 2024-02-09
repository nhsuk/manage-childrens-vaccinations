require "csv"

class CohortList
  include ActiveModel::Model

  EXPECTED_HEADERS = %w[
    SUBMITTED_AT
    EOI_ID
    SCHOOL_ID
    SCHOOL_NAME
    PARENT_NAME
    PARENT_RELATIONSHIP
    PARENT_EMAIL
    PARENT_PHONE
    CHILD_FIRST_NAME
    CHILD_LAST_NAME
    CHILD_COMMON_NAME
    CHILD_DATE_OF_BIRTH
    CHILD_ADDRESS_LINE_1
    CHILD_ADDRESS_LINE_2
    CHILD_ADDRESS_TOWN
    CHILD_ADDRESS_POSTCODE
    CHILD_NHS_NUMBER
  ].freeze

  REGISTRATION_ATTRS = %i[
    created_at
    id
    location_id
    location_name
    parent_name
    formatted_parent_relationship
    parent_email
    parent_phone
    first_name
    last_name
    common_name
    date_of_birth
    address_line_1
    address_line_2
    address_town
    address_postcode
    nhs_number
  ].freeze

  attr_accessor :csv, :csv_is_malformed, :data, :missing_headers, :rows, :team

  validates :csv, presence: true
  validate :csv_is_valid
  validate :headers_are_valid
  validate :rows_are_valid
  validate :cohort_is_within_team_limit

  def load_data!
    return if invalid?

    self.data ||= CSV.parse(csv.read, headers: true, skip_blanks: true)
  rescue CSV::MalformedCSVError
    self.csv_is_malformed = true
  ensure
    csv.close if csv.respond_to?(:close)
  end

  def parse_rows!
    if data.headers != EXPECTED_HEADERS
      self.missing_headers = EXPECTED_HEADERS - data.headers
      return
    end

    self.rows =
      data
        .map { |raw_row| raw_row.to_h.transform_keys { _1.downcase.to_sym } }
        .map { CohortListRow.new(_1) }
  end

  def generate_patients!
    return if invalid?

    rows.each do |row|
      location = Location.find(row.school_id)
      patient = location.patients.new(row.to_patient)
      patient.save!
    end
  end

  def self.from_registrations(registrations)
    new.tap do |ch|
      ch.data = registrations.map { _1.values_at(*REGISTRATION_ATTRS) }
    end
  end

  def to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << EXPECTED_HEADERS

      data.each { csv << _1 }
    end
  end

  private

  def csv_is_valid
    return unless csv_is_malformed

    errors.add(:csv, :invalid)
  end

  def headers_are_valid
    return unless missing_headers

    html_missing_headers = missing_headers.map { "<code>#{_1}</code>" }
    errors.add(
      :csv,
      "The file is missing the following headers: #{html_missing_headers.join(", ")}"
    )
  end

  def rows_are_valid
    return unless rows

    rows.each.with_index do |row, index|
      unless row.valid?
        # Row 0 is the header row, but humans would call it Row 1. That's also
        # what it would be shown as in Excel. The first row of data is Row 2.
        errors.add("row_#{index + 2}".to_sym, row.errors.full_messages)
      end
    end
  end

  def cohort_is_within_team_limit
    return unless data

    if data.size > team.remaining_cohort_size
      errors.add(:csv, :too_large, remaining: team.remaining_cohort_size)
    end
  end
end
