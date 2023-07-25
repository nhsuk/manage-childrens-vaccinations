# == Schema Information
#
# Table name: vaccines
#
#  id         :bigint           not null, primary key
#  brand      :text
#  method     :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_vaccines_on_type  (type) UNIQUE
#
FactoryBot.define do
  factory :vaccine do

    initialize_with { Vaccine.find_or_initialize_by(type:, brand:, method:) }

    hpv

    trait :with_batches do
      transient do
        batch_count { 3 }
      end

      after(:create) do |vaccine, evaluator|
        create_list(:batch, evaluator.batch_count, vaccine:)
      end
    end

    trait :flu do
      fluenz_tetra
    end

    trait :fluenz_tetra do
      type { "flu" }
      brand { "Fluenz Tetra" }
      add_attribute(:method) { :nasal }
    end

    trait :fluerix_tetra do
      type { "flu" }
      brand { "Fluerix Tetra" }
      add_attribute(:method) { :injection }
    end

    trait :hpv do
      gardasil_9
    end

    trait :gardasil_9 do
      type { "HPV" }
      brand { "Gardasil 9" }
      add_attribute(:method) { :injection }
    end
  end
end
