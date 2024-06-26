# frozen_string_literal: true

# == Schema Information
#
# Table name: vaccination_records
#
#  id                 :bigint           not null, primary key
#  administered       :boolean
#  delivery_method    :integer
#  delivery_site      :integer
#  notes              :text
#  reason             :integer
#  recorded_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  batch_id           :bigint
#  patient_session_id :bigint           not null
#  user_id            :bigint
#
# Indexes
#
#  index_vaccination_records_on_batch_id            (batch_id)
#  index_vaccination_records_on_patient_session_id  (patient_session_id)
#  index_vaccination_records_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (batch_id => batches.id)
#  fk_rails_...  (patient_session_id => patient_sessions.id)
#  fk_rails_...  (user_id => users.id)
#
class VaccinationRecord < ApplicationRecord
  audited associated_with: :patient_session

  attr_accessor :delivery_site_other

  belongs_to :patient_session
  belongs_to :batch, optional: true
  belongs_to :user
  has_one :vaccine, through: :batch
  has_one :session, through: :patient_session
  has_one :patient, through: :patient_session
  has_one :campaign, through: :session
  has_one :team, through: :campaign

  scope :administered, -> { where(administered: true) }
  scope :recorded, -> { where.not(recorded_at: nil) }

  default_scope { recorded }

  enum :delivery_method, %w[intramuscular subcutaneous], prefix: true
  enum :delivery_site,
       %w[
         left_arm
         right_arm
         left_arm_upper_position
         left_arm_lower_position
         right_arm_upper_position
         right_arm_lower_position
         left_thigh
         right_thigh
       ],
       prefix: true
  enum :reason,
       %i[
         refused
         not_well
         contraindications
         already_had
         absent_from_school
         absent_from_session
       ]

  encrypts :notes

  validates :notes, length: { maximum: 1000 }

  validates :administered, inclusion: [true, false]
  validates :batch_id, presence: true, on: :edit_batch, if: -> { administered }
  validates :delivery_site,
            presence: true,
            inclusion: {
              in: delivery_sites.keys
            },
            if: -> { administered && !delivery_site_other }
  validates :delivery_method,
            presence: true,
            inclusion: {
              in: delivery_methods.keys
            },
            if: -> { administered && delivery_site.present? }
  validates :delivery_site,
            presence: true,
            inclusion: {
              in: delivery_sites.keys
            },
            on: :edit_delivery,
            if: -> { administered }
  validates :delivery_method,
            presence: true,
            inclusion: {
              in: delivery_methods.keys
            },
            on: :edit_delivery,
            if: -> { administered }
  validates :reason,
            inclusion: {
              in: reasons.keys
            },
            on: :edit_reason,
            if: -> { !administered }

  def vaccine_name
    patient_session.session.campaign.vaccines.first.type
  end

  def location_name
    patient_session.session.location&.name
  end

  def not_administered?
    !administered?
  end
end
