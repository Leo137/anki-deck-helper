# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Study::DeckStats do
  let(:user) { create(:user) }
  let(:deck) { create(:deck, user:, status: :ready) }

  def record_responses(card, pattern)
    pattern.each_with_index do |correct, index|
      create(:deck_card_study_response, user:, deck_card: card, correct:,
                                         created_at: index.minutes.ago)
    end
  end

  it 'counts cards without responses as not reviewed' do
    create(:deck_card, :complete, deck:, position: 1)
    create(:deck_card, :complete, deck:, position: 2)

    summary = described_class.new(deck:, user:).summary

    expect(summary).to eq(
      not_reviewed_count: 2,
      young_count: 0,
      learning_count: 0,
      mature_count: 0
    )
  end

  it 'aggregates maturity stages across reviewed cards' do
    young_card = create(:deck_card, :complete, deck:, position: 1)
    learning_card = create(:deck_card, :complete, deck:, position: 2)
    mature_card = create(:deck_card, :complete, deck:, position: 3)
    create(:deck_card, :complete, deck:, position: 4)

    record_responses(young_card, [true])
    record_responses(learning_card, [true, true, true, true])
    record_responses(mature_card, Array.new(8, true))

    summary = described_class.new(deck:, user:).summary

    expect(summary).to eq(
      not_reviewed_count: 1,
      young_count: 1,
      learning_count: 1,
      mature_count: 1
    )
  end
end
