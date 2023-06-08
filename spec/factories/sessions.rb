# == Schema Information
#
# Table name: sessions
#
#  id          :bigint           not null, primary key
#  date        :datetime
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  campaign_id :bigint           not null
#  location_id :bigint
#
# Indexes
#
#  index_sessions_on_campaign_id  (campaign_id)
#
FactoryBot.define do
  factory :session do
    campaign { create :campaign }
    location

    date { Time.zone.today }
    name { "#{campaign.name} session at #{location.name}" }

    after :create do |session|
      create_list :patient, 100, sessions: [session]
    end
  end
end
