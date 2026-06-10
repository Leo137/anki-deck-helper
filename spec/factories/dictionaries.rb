# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary do
    sequence(:name) { |n| "dictionary#{n}" }
    language

    trait :english_jmdict do
      name { 'jmdict-eng-3.5.0' }
      association :language, factory: %i[language english]
    end
  end
end
