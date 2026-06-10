# frozen_string_literal: true

FactoryBot.define do
  factory :word_set do
    sequence(:name) { |n| "word_set_#{n}" }
    origin { :normal }

    trait :takoboto do
      origin { :takoboto }
    end
  end
end
