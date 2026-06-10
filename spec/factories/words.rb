# frozen_string_literal: true

FactoryBot.define do
  factory :word do
    sequence(:content) { |n| "word#{n}" }
    kana { nil }
    word_count { 0 }

    trait :with_kana do
      sequence(:kana) { |n| "かな#{n}" }
    end

    trait :counter do
      sequence(:content) { |n| "~counter#{n}" }
    end
  end
end
