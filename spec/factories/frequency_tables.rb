# frozen_string_literal: true

FactoryBot.define do
  factory :frequency_table do
    sequence(:name) { |n| "frequency_table_#{n}" }
    max_frequency { nil }
  end
end
