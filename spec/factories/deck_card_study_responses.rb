# frozen_string_literal: true

FactoryBot.define do
  factory :deck_card_study_response, class: 'Deck::Card::StudyResponse' do
    user
    association :deck_card, factory: %i[deck_card complete]
    correct { true }
  end
end
