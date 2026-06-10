# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_meaning_field, class: 'Dictionary::Meaning::Field' do
    dictionary_meaning
    sequence(:code) { |n| "field#{n}" }
  end
end
