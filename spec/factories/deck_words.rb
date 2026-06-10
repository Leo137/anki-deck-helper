# frozen_string_literal: true

FactoryBot.define do
  factory :deck_word do
    deck
    word
    sequence(:position) { |n| n }
  end
end
