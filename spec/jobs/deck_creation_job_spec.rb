# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckCreationJob, type: :job do
  let!(:user) { create(:user, preferred_language: 'en') }
  let!(:dictionary) { create(:dictionary, :english_jmdict) }
  let!(:frequency_table) { create(:frequency_table, max_frequency: 100) }
  let!(:word_set) { create(:word_set) }
  let!(:word) { create(:word) }
  let!(:deck) { create(:deck, user:, status: :pending) }

  before do
    DeckCreationLogger.reset!
    FileUtils.rm_f(DeckCreationLogger::LOG_PATH)
    word_set.words << word
    create(:word_frequency, word:, frequency_table:, frequency: 5)
  end

  it 'generates deck cards in the background' do
    described_class.perform_now(deck.id, word_set_ids: [word_set.id], frequency_table_ids: [frequency_table.id])

    expect(deck.reload).to be_ready
    expect(deck.cards.count).to eq(1)
  end

  it 'writes execution details to the deck creation log' do
    FileUtils.rm_f(DeckCreationLogger::LOG_PATH)

    described_class.perform_now(deck.id, word_set_ids: [word_set.id], frequency_table_ids: [frequency_table.id])

    log = File.read(DeckCreationLogger::LOG_PATH)
    expect(log).to include('DeckCreationJob started')
    expect(log).to include('Deck generation started')
    expect(log).to include('Deck generation completed')
    expect(log).to include('DeckCreationJob finished')
    expect(log).to include("deck_id=#{deck.id}")
  end
end
