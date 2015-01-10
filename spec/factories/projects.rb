FactoryGirl.define do
  factory :project do
    id 2020
    title 'Go Creative'
    description 'Crowdfunding platform'
    amount_required 100000
    min_amount_per_contribution 100
    end_date { 30.days.from_now.end_of_day }

    # Association: belongs_to :user
    association :user, factory: :user

    trait :published do
      state :published
    end

    trait :unpublished do
      state :unpublished
    end

    trait :created do
      state :created
    end

    trait :charity do
      type 'CharityProject'
    end

    trait :investment do
      type 'InvestmentProject'
    end

    factory :published_investment_project, traits: [:published, :investment]
    factory :published_charity_project, traits: [:published, :charity]
    factory :unpublished_investment_project, traits: [:unpublished, :investment]
    factory :unpublished_charity_project, traits: [:unpublished, :charity]
    factory :created_investment_project, traits: [:created, :investment]
    factory :created_charity_project, traits: [:created, :charity]

  end

end
