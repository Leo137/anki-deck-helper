# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Study::CardPicker do
  let(:user) { create(:user) }
  let(:deck) { create(:deck, user:, status: :ready) }

  def pick(exclude_card_id: nil)
    described_class.new(deck:, user:, exclude_card_id:).pick
  end

  it 'returns nil when the deck has no cards' do
    expect(pick).to be_nil
  end

  it 'returns a card from the deck' do
    card = create(:deck_card, :complete, deck:, position: 1)

    expect(pick).to eq(card)
  end

  it 'excludes the given card when another card is available' do
    first = create(:deck_card, :complete, deck:, position: 1)
    second = create(:deck_card, :complete, deck:, position: 2)

    allow_any_instance_of(described_class).to receive(:rand).and_return(0.0)

    expect(pick(exclude_card_id: first.id)).to eq(second)
  end

  it 'falls back to the excluded card when it is the only card' do
    card = create(:deck_card, :complete, deck:, position: 1)

    expect(pick(exclude_card_id: card.id)).to eq(card)
  end

  it 'favors cards with recent failures' do
    struggling = create(:deck_card, :complete, deck:, position: 1)
    mastered = create(:deck_card, :complete, deck:, position: 2)

    create(:deck_card_study_response, user:, deck_card: struggling, correct: false,
                                      created_at: 1.hour.ago)
    5.times do
      create(:deck_card_study_response, user:, deck_card: mastered, correct: true,
                                        created_at: 2.days.ago)
    end

    allow_any_instance_of(described_class).to receive(:rand).and_return(0.0)

    expect(pick).to eq(struggling)
  end

  it 'favors cards with low accuracy' do
    low_accuracy = create(:deck_card, :complete, deck:, position: 1)
    high_accuracy = create(:deck_card, :complete, deck:, position: 2)

    create(:deck_card_study_response, user:, deck_card: low_accuracy, correct: false)
    create(:deck_card_study_response, user:, deck_card: low_accuracy, correct: true)
    4.times do
      create(:deck_card_study_response, user:, deck_card: high_accuracy, correct: true)
    end

    allow_any_instance_of(described_class).to receive(:rand).and_return(0.0)

    expect(pick).to eq(low_accuracy)
  end
end
