FactoryGirl.define do
  factory :contribution do
    card_number 4032031606156262
    card_verification 111
    brand 'visa'
    card_expires_on { 1.years.from_now }
    created_at { DateTime.current }
    updated_at { 1.days.from_now }

    trait :accepted do
      state :accepted
    end

    trait :rejected do
      state :rejected
    end

    trait :payment_initiated do
      state :payment_initiated
    end

    trait :payment_error_occurred do
      state :payment_error_occurred
    end

  end

end
