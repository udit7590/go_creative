FactoryGirl.define do
  factory :user do
    first_name 'martin'
    last_name 'mathew'
    sequence(:email) { |n| "user_#{n}@gocreative.com" }
    password 'user1234'
    password_confirmation 'user1234'
    confirmed_at { DateTime.current }

    trait :without_name do
      first_name nil
      last_name nil
    end

    trait :pan_details do
      pan_card 'AAAAA5555A'
      pan_card_copy_file_name 'pan'
      pan_card_copy_file_size 10000
      pan_card_copy_content_type 'image/png'
      pan_card_copy_updated_at { DateTime.current }
    end

    trait :pan_verified do
      pan_verified_at { DateTime.current }
    end

    factory :user_without_name, traits: [:without_name]
    factory :user_with_pan, traits: [:pan_details, :pan_verified]

    #Has verified pan and address (has_many association)
    factory :user_complete, traits: [:pan_details, :pan_verified] do
      after(:create) do |user, evaluator|
        user.addresses = [create(:primary_address, user: user), create(:current_address, user: user)]
      end
    end

  end
end
