FactoryBot.define do
  factory :address do
    full_address { 'rails city' }
    city {'delhi'}
    country {'india'}
    pincode {110060}
    created_at { DateTime.current }
    updated_at { DateTime.current }

    # Association: belongs_to :user, :project
    association :user, factory: :user

    trait :primary do
      primary {true}
    end

    trait :current do
      primary {false}
    end

    trait :proof do
      address_proof_file_name {'address'}
      address_proof_file_size {10000}
      address_proof_content_type {'image/png'}
      address_proof_updated_at { DateTime.current }
    end

    trait :verified do
      verified_at { DateTime.current }
    end

    factory :primary_address, traits: [:primary, :proof, :verified]
    factory :current_address, traits: [:current, :proof, :verified]

  end
end
