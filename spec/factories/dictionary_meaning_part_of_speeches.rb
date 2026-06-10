# frozen_string_literal: true

FactoryBot.define do
  factory :dictionary_meaning_part_of_speech, class: 'Dictionary::Meaning::PartOfSpeech' do
    dictionary_meaning
    sequence(:code) { |n| "pos#{n}" }
  end
end
