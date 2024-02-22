# == Schema Information
#
# Table name: consents
#
#  id                          :bigint           not null, primary key
#  health_answers              :jsonb
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
  include WizardFormConcern
  audited

  attr_accessor :triage, :patient_session

  has_one :consent_form
  belongs_to :patient
  belongs_to :campaign

  scope :submitted_for_campaign,
        ->(campaign) { where(campaign:).where.not(recorded_at: nil) }

  enum :parent_contact_method, %w[text voice other any], prefix: true
  enum :parent_relationship, %w[mother father guardian other], prefix: true
  enum :response, %w[given refused not_provided], prefix: true
  enum :reason_for_refusal,
       %w[
         contains_gelatine
         already_vaccinated
         will_be_vaccinated_elsewhere
         medical_reasons
         personal_choice
         other
       ],
       prefix: true
  enum :route, %i[website phone paper in_person self_consent], prefix: "via"

  serialize :health_answers, coder: HealthAnswer::ArraySerializer

  encrypts :health_answers,
           :parent_contact_method_other,
           :parent_email,
           :parent_name,
           :parent_phone,
           :parent_relationship_other,
           :reason_for_refusal_other

  validates :parent_contact_method_other,
            :parent_email,
            :parent_name,
            :parent_phone,
            :parent_relationship_other,
            length: {
              maximum: 300
            }

  validates :reason_for_refusal_other, length: { maximum: 1000 }

  on_wizard_step :gillick, exact: true do
    validate :patient_session_valid?
  end

  on_wizard_step :who do
    validates :parent_name, presence: true
    validates :parent_phone, presence: true
    validates :parent_phone, phone: true
    validates :parent_relationship,
              inclusion: {
                in: Consent.parent_relationships.keys
              },
              presence: true
    validates :parent_relationship_other,
              presence: true,
              if: -> { parent_relationship == "other" }
  end

  on_wizard_step :agree do
    validates :response,
              inclusion: {
                in: Consent.responses.keys
              },
              presence: true
  end

  on_wizard_step :reason do
    validates :reason_for_refusal,
              inclusion: {
                in: Consent.reason_for_refusals.keys
              },
              presence: true
    validates :reason_for_refusal_other,
              presence: true,
              if: -> { reason_for_refusal == "other" }
  end

  on_wizard_step :questions do
    validate :health_answers_valid?
  end

  on_wizard_step :questions, exact: true do
    validate :triage_valid?
  end

  def form_steps
    [
      (:assessing_gillick if via_self_consent?),
      (:gillick if via_self_consent?),
      (:who if via_phone?),
      :agree,
      (:questions if response_given?),
      (:reason if response_refused?),
      :confirm
    ].compact
  end

  def name
    via_self_consent? ? patient.full_name : parent_name
  end

  def triage_needed?
    response_given? &&
      (parent_relationship_other? || health_answers_require_follow_up?)
  end

  def who_responded
    if parent_relationship == "other"
      parent_relationship_other
    else
      human_enum_name(:parent_relationship)
    end.capitalize
  end

  def health_answers_require_follow_up?
    health_answers&.any? { |question| question.response.downcase == "yes" }
  end

  def reasons_triage_needed
    reasons = []
    reasons << "Check parental responsibility" if parent_relationship_other?
    if health_answers_require_follow_up?
      reasons << "Health questions need triage"
    end
    reasons
  end

  def self.from_consent_form(consent_form, patient_session)
    consent =
      create!(
        consent_form:,
        campaign: consent_form.session.campaign,
        patient: patient_session.patient,
        parent_contact_method: consent_form.contact_method,
        parent_contact_method_other: consent_form.contact_method_other,
        parent_email: consent_form.parent_email,
        parent_name: consent_form.parent_name,
        parent_phone: consent_form.parent_phone,
        parent_relationship: consent_form.parent_relationship,
        parent_relationship_other: consent_form.parent_relationship_other,
        reason_for_refusal: consent_form.reason,
        reason_for_refusal_other: consent_form.reason_notes,
        recorded_at: Time.zone.now,
        response: consent_form.response,
        route: "website",
        health_answers: consent_form.health_answers
      )
    patient_session.do_consent! if patient_session.may_do_consent?
    consent
  end

  private

  def health_answers_valid?
    return if health_answers.map(&:valid?).all?

    health_answers.each_with_index do |health_answer, index|
      health_answer.errors.messages.each do |field, messages|
        messages.each do |message|
          errors.add("question-#{index}-#{field}", message)
        end
      end
    end
  end

  def patient_session_valid?
    return if patient_session.valid?(:edit_gillick)

    errors.add(
      :gillick_competent,
      patient_session.errors.messages[:gillick_competent].first
    )
    errors.add(
      :gillick_competence_notes,
      patient_session.errors.messages[:gillick_competence_notes].first
    )
  end

  def triage_valid?
    return if triage.valid?(:consent)

    triage.errors.each do |error|
      errors.add(:"triage_#{error.attribute}", error.message)
    end
  end
end
