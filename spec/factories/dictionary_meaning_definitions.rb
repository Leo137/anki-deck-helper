# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_meaning_definition, class: 'Dictionary::Meaning::Definition' do
    dictionary_meaning
    sequence(:text) { |n| "definition #{n}" }
  end
end
