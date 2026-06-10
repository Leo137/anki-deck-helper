# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_entry, class: 'Dictionary::Entry' do
    sequence(:text) { |n| "entry_text_#{n}" }
    sequence(:jmdict_id) { |n| "jmdict_#{n}" }
  end
end
