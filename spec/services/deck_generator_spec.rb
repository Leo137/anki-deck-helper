# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckGenerator do
  let!(:user) { create(:user, preferred_language: 'en') }
  let!(:dictionary) { create(:dictionary, :english_jmdict) }
  let!(:frequency_table) { create(:frequency_table, name: 'jpdb', max_frequency: 100) }
  let!(:word_set) { create(:word_set, name: 'core') }
  let!(:word) { create(:word, content: '食べる') }
  let!(:deck) { create(:deck, user:, status: :pending) }

  before do
    word_set.words << word
    create(:word_frequency, word:, frequency_table:, frequency: 10)
  end

  describe '#call' do
    it 'creates ordered cards with Anki-style front and back fields' do
      described_class.new(
        deck:,
        word_set_ids: [word_set.id],
        frequency_table_ids: [frequency_table.id]
      ).call

      deck.reload
      expect(deck).to be_ready
      expect(deck.generation_progress).to eq(100)
      expect(deck.cards.count).to eq(1)

      card = deck.cards.first
      expect(card.position).to eq(1)
      expect(card.front_field.html_content).to eq('<h1>食べる</h1>')
      expect(card.back_field.html_content).to be_present
    end

    it 'marks the deck as failed when no words are found' do
      described_class.new(
        deck:,
        word_set_ids: [create(:word_set).id],
        frequency_table_ids: [frequency_table.id]
      ).call

      expect(deck.reload).to be_failed
      expect(deck.error_message).to eq('No words found for the selected word sets')
    end

    it 'uses a placeholder when generated HTML is blank' do
      generator = instance_double(
        AnkiCardGenerator,
        generate_front: '',
        generate_back: ''
      )
      allow(AnkiCardGenerator).to receive(:new).and_return(generator)

      described_class.new(
        deck:,
        word_set_ids: [word_set.id],
        frequency_table_ids: [frequency_table.id]
      ).call

      card = deck.reload.cards.first
      expect(card.front_field.html_content).to eq('<p>No content available.</p>')
      expect(card.back_field.html_content).to eq('<p>No content available.</p>')
    end
  end
end
