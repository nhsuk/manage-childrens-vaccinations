# == Schema Information
#
# Table name: batches
#
#  id         :bigint           not null, primary key
#  expiry     :date
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vaccine_id :bigint           not null
#
# Indexes
#
#  index_batches_on_vaccine_id  (vaccine_id)
#
# Foreign Keys
#
#  fk_rails_...  (vaccine_id => vaccines.id)
#
#!/usr/bin/env ruby

FactoryBot.define do
  factory :batch do
    transient do
      prefix { ("A".."Z").to_a.sample(2).join }
      days_to_expiry_range { 10..50 }
      days_to_expiry { rand(days_to_expiry_range) }
    end

    name { "#{prefix}#{sprintf("%04d", rand(10_000))}" }
    expiry { Time.zone.today + days_to_expiry }
    vaccine { create(:vaccine) }
  end
end
