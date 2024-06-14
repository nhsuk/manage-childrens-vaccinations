# == Schema Information
#
# Table name: parents
#
#  id                   :bigint           not null, primary key
#  contact_method       :integer
#  contact_method_other :text
#  email                :string
#  name                 :string
#  phone                :string
#  relationship         :integer
#  relationship_other   :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Parent < ApplicationRecord
  audited

  has_one :patient

  attr_accessor :parental_responsibility

  enum :contact_method, %w[text voice other any], prefix: true
  enum :relationship, %w[mother father guardian other], prefix: true

  encrypts :email, :name, :phone, :relationship_other

  validates :name, presence: true
  validates :phone, phone: true, if: -> { phone.present? }
  validates :email, presence: true, email: true
  validates :relationship,
            inclusion: {
              in: Parent.relationships.keys
            },
            presence: true
  validates :relationship_other, presence: true, if: -> { relationship_other? }
  validate :has_parental_responsibility, if: -> { relationship_other? }
  validates :contact_method_other,
            :email,
            :name,
            :phone,
            :relationship_other,
            length: {
              maximum: 300
            }

  def relationship_label
    if relationship == "other"
      relationship_other
    else
      human_enum_name(:relationship)
    end.capitalize
  end

  def phone_contact_method_description
    if contact_method_other.present?
      "Other – #{contact_method_other}"
    else
      human_enum_name(:contact_method)
    end
  end

  def phone=(str)
    super str.blank? ? nil : str.to_s.gsub(/\s/, "")
  end

  def email=(str)
    super str.nil? ? nil : str.to_s.downcase.strip
  end

  def has_parental_responsibility
    return if parental_responsibility == "yes"
    if parental_responsibility == "no" && validation_context != :manage_consent
      return
    end

    if validation_context == :manage_consent
      errors.add(:parental_responsibility, :inclusion)
    else
      errors.add(:parental_responsibility, :inclusion_on_consent_form)
    end
  end
end
