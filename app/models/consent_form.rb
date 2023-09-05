# == Schema Information
#
# Table name: consent_forms
#
#  id              :bigint           not null, primary key
#  common_name     :text
#  date_of_birth   :date
#  first_name      :text
#  last_name       :text
#  recorded_at     :datetime
#  use_common_name :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  session_id      :bigint           not null
#
# Indexes
#
#  index_consent_forms_on_session_id  (session_id)
#
# Foreign Keys
#
#  fk_rails_...  (session_id => sessions.id)
#

class ConsentForm < ApplicationRecord
  cattr_accessor :form_steps do
    %i[name date_of_birth school]
  end

  attr_accessor :form_step, :is_this_their_school

  audited

  belongs_to :session

  with_options if: -> { required_for_step?(:name) } do
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :use_common_name, inclusion: { in: [true, false] }
    validates :common_name, presence: true, if: :use_common_name?
  end

  with_options if: -> { required_for_step?(:date_of_birth) } do
    validates :date_of_birth,
              presence: true,
              comparison: {
                less_than: Time.zone.today,
                greater_than_or_equal_to: 22.years.ago.to_date,
                less_than_or_equal_to: 3.years.ago.to_date
              }
  end

  with_options if: -> { required_for_step?(:school, exact: true) } do
    validates :is_this_their_school,
              presence: true,
              inclusion: {
                in: %w[yes no]
              }
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  private

  def required_for_step?(step, exact: false)
    # Exact means that the form_step must match the step
    return false if exact && form_step != step

    # All fields are required if no form_step is set
    return true if form_step.nil?

    # Otherwise, all fields from previous and current steps are required
    return true if form_steps.index(step) <= form_steps.index(form_step)

    false
  end
end
