# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { 'Password1!' }
    password_confirmation { 'Password1!' }
    preferred_language { 'en' }
  end
end
