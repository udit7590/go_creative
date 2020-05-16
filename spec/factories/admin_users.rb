FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin_#{n}@gocreative.com" }
    password {'admin123'}
    password_confirmation {'admin123'}
  end
end
