# frozen_string_literal: true

FactoryBot.define do
  factory :deck do
    user
    sequence(:name) { |n| "deck-#{n}" }

    trait :with_cards do
      transient do
        cards_count { 3 }
      end

      after(:create) do |deck, evaluator|
        evaluator.cards_count.times do |index|
          create(:deck_card, :complete, deck:, position: index + 1)
        end
      end
    end
  end
end
