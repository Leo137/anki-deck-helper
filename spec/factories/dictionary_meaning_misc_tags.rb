# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_meaning_misc_tag, class: 'Dictionary::Meaning::MiscTag' do
    dictionary_meaning
    sequence(:code) { |n| "misc#{n}" }
  end
end
