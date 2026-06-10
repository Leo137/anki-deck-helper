# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_reading, class: 'Dictionary::Reading' do
    dictionary_entry
    sequence(:text) { |n| "reading_#{n}" }
    is_kana { false }

    trait :kana do
      is_kana { true }
    end
  end
end
