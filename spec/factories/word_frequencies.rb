# frozen_string_literal: true

FactoryBot.define do
  factory :word_frequency do
    word
    frequency_table
    frequency { 10 }
  end
end
