FactoryGirl.define do
  factory :user do
    first_name 'martin'
    last_name 'mathew'
    sequence(:email) { |n| "user_#{n}@gocreative.com" }
    password 'user123'
    password_confirmation 'user123'
    confirmed_at { DateTime.current }
  end
end
