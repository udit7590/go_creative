FactoryGirl.define do
  factory :comment do
    description 'Comment'

    # Association: belongs_to :user, :project
    association :user, factory: :user
    association :project, factory: :project

    trait :public_comment do
      visible_to_all true
    end

    trait :private_comment do
      visible_to_all false
    end

    trait :spam do
      spam true
    end

    trait :deleted do
      deleted true
      deleted_at { DateTime.current }
    end

    factory :public_comment, traits: [:public_comment]
    factory :private_comment, traits: [:private_comment]
    factory :spam_comment, traits: [:spam]
    factory :deleted_spam_comment, traits: [:deleted, :spam]

  end

end
