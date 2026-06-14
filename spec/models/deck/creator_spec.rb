# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Creator do
  let!(:user) { create(:user) }
  let!(:word_set) { create(:word_set) }
  let!(:frequency_table) { create(:frequency_table) }

  describe '#call' do
    it 'creates a pending deck and enqueues a background job' do
      expect do
        described_class.new(
          user:,
          name: 'Daily Review',
          word_set_ids: [word_set.id],
          frequency_table_ids: [frequency_table.id]
        ).call
      end.to have_enqueued_job(DeckCreationJob)

      deck = user.decks.last
      expect(deck.name).to eq('Daily Review')
      expect(deck).to be_pending
    end

    it 'raises when required selections are missing' do
      expect do
        described_class.new(user:, name: '', word_set_ids: [], frequency_table_ids: []).call
      end.to raise_error(Deck::Creator::Error, 'Name is required')
    end
  end
end
