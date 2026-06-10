# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_meaning, class: 'Dictionary::Meaning' do
    dictionary_entry
  end
end
