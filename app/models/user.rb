# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  full_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  registration           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable,
         :lockable,
         :trackable,
         :timeoutable,
         :recoverable,
         :validatable
  devise :pwned_password unless Rails.env.test?

  has_and_belongs_to_many :teams

  encrypts :email, deterministic: true
  encrypts :full_name

  scope :recently_active,
        -> { where(last_sign_in_at: 1.week.ago..Time.current) }

  def team
    # TODO: Update the app to properly support multiple teams per user
    teams.first
  end
end
