# == Schema Information
#
# Table name: locations
#
#  id                             :bigint           not null, primary key
#  address                        :text
#  county                         :text
#  locality                       :text
#  name                           :text
#  permission_to_observe_required :boolean
#  postcode                       :text
#  registration_open              :boolean          default(FALSE)
#  town                           :text
#  url                            :text
#  urn                            :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  team_id                        :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class Location < ApplicationRecord
  audited

  has_many :sessions
  has_many :patients
  has_many :consent_forms, through: :sessions
  has_many :registrations
  belongs_to :team

  validates :name, presence: true
end
