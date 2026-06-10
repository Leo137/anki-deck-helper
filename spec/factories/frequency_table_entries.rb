# frozen_string_literal: true

FactoryBot.define do
  factory :frequency_table_entry do
    frequency_table
    sequence(:content) { |n| "entry#{n}" }
    kana { nil }
    frequency { 1 }
  end
end
