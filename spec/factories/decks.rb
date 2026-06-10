# frozen_string_literal: true

FactoryBot.define do
  factory :deck do
    user
    sequence(:name) { |n| "deck-#{n}" }

    trait :with_words do
      transient do
        words_count { 3 }
      end

      after(:create) do |deck, evaluator|
        words = create_list(:word, evaluator.words_count)
        words.each_with_index do |word, index|
          deck.deck_words.create!(word:, position: index + 1)
        end
      end
    end
  end
end
