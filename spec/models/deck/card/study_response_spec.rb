# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Card::StudyResponse, type: :model do
  describe 'validations' do
    it 'requires correct to be true or false' do
      response = build(:deck_card_study_response, correct: nil)
      expect(response).not_to be_valid
      expect(response.errors[:correct]).to be_present
    end

    it 'rejects cards from another user deck' do
      owner = create(:user)
      other_user = create(:user)
      deck = create(:deck, user: owner)
      card = create(:deck_card, :complete, deck:)

      response = build(:deck_card_study_response, user: other_user, deck_card: card)

      expect(response).not_to be_valid
      expect(response.errors[:deck_card]).to include('must belong to one of the user decks')
    end
  end

  describe '.stats_for' do
    it 'returns aggregated study statistics for a card' do
      user = create(:user)
      deck = create(:deck, user:)
      card = create(:deck_card, :complete, deck:)

      create(:deck_card_study_response, user:, deck_card: card, correct: true,
                                        created_at: 2.days.ago)
      create(:deck_card_study_response, user:, deck_card: card, correct: false,
                                        created_at: 1.day.ago)

      stats = described_class.stats_for(user:, card:)

      expect(stats).to include(
        know_count: 1,
        dont_know_count: 1,
        total_responses: 2,
        accuracy_rate: 0.5,
        last_correct: false
      )
      expect(stats[:last_responded_at]).to be_present
    end

    it 'returns nil accuracy when there are no responses' do
      user = create(:user)
      deck = create(:deck, user:)
      card = create(:deck_card, :complete, deck:)

      stats = described_class.stats_for(user:, card:)

      expect(stats).to include(
        know_count: 0,
        dont_know_count: 0,
        total_responses: 0,
        accuracy_rate: nil,
        last_responded_at: nil,
        last_correct: nil
      )
    end
  end
end
