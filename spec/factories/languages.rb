# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    sequence(:code) { |n| "lang#{n}" }

    trait :english do
      code { 'en' }
      initialize_with { Language.find_or_create_by!(code: 'en') }
    end
  end
end
