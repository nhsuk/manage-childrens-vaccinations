# == Schema Information
#
# Table name: consents
#
#  id                          :bigint           not null, primary key
#  address_line_1              :text
#  address_line_2              :text
#  address_postcode            :text
#  address_town                :text
#  childs_common_name          :text
#  childs_dob                  :date
#  childs_name                 :text
#  gp_name                     :text
#  gp_response                 :integer
#  health_questions            :jsonb
#  parent_contact_method       :integer
#  parent_contact_method_other :text
#  parent_email                :text
#  parent_name                 :text
#  parent_phone                :text
#  parent_relationship         :integer
#  parent_relationship_other   :text
#  reason_for_refusal          :integer
#  reason_for_refusal_other    :text
#  recorded_at                 :datetime
#  response                    :integer
#  route                       :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  campaign_id                 :bigint           not null
#  patient_id                  :bigint           not null
#
# Indexes
#
#  index_consents_on_campaign_id  (campaign_id)
#  index_consents_on_patient_id   (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (patient_id => patients.id)
#

class Consent < ApplicationRecord
  audited

  belongs_to :patient
  belongs_to :campaign

  scope :submitted_for_campaign,
        ->(campaign) { where(campaign:).where.not(recorded_at: nil) }

  enum :parent_relationship, %w[mother father guardian other], prefix: true
  enum :response, %w[given refused not_provided], prefix: true
  enum :reason_for_refusal,
       %w[
         already_vaccinated
         will_be_vaccinated_elsewhere
         medical
         personal_choice
         other
       ],
       prefix: true
  enum :gp_response, %w[yes no dont_know]
  enum :route, %i[website phone paper in_person self_consent], prefix: "via"

  with_options on: :edit_who do
    validates :parent_name, presence: true
    validates :parent_phone, presence: true
    validates :parent_phone, phone_number: true
    validates :parent_relationship,
              inclusion: {
                in: Consent.parent_relationships.keys
              },
              presence: true
    validates :parent_relationship_other,
              presence: true,
              if: -> { parent_relationship == "other" }
  end

  with_options on: :edit_consent do
    validates :response,
              inclusion: {
                in: Consent.responses.keys
              },
              presence: true
  end

  with_options on: :edit_reason do
    validates :reason_for_refusal,
              inclusion: {
                in: Consent.reason_for_refusals.keys
              },
              presence: true
    validates :reason_for_refusal_other,
              presence: true,
              if: -> { reason_for_refusal == "other" }
  end

  def name
    via_self_consent? ? patient.full_name : parent_name
  end

  def triage_needed?
    response_given? &&
      (parent_relationship_other? || health_questions_require_follow_up?)
  end

  def who_responded
    if parent_relationship == "other"
      parent_relationship_other
    else
      human_enum_name(:parent_relationship)
    end.capitalize
  end

  def health_questions_require_follow_up?
    health_questions&.any? { |question| question["response"].downcase == "yes" }
  end

  def reasons_triage_needed
    reasons = []
    reasons << "Check parental responsibility" if parent_relationship_other?
    if health_questions_require_follow_up?
      reasons << "Health questions need triage"
    end
    reasons
  end
end
