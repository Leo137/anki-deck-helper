# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckAnkiExportGenerator do
  let!(:user) { create(:user) }
  let!(:deck) { create(:deck, user:, name: 'Core Vocab', status: :ready) }

  def create_card(deck:, position:, front:, back:)
    card = build(:deck_card, deck:, position:)
    card.fields.build(side: :front, html_content: front)
    card.fields.build(side: :back, html_content: back)
    card.save!
    card
  end

  describe '#call' do
    it 'writes an Anki import file using existing card front and back fields' do
      create_card(deck:, position: 1, front: '<h1>食べる</h1>', back: '<p>to eat</p>')
      create_card(deck:, position: 2, front: '<h1>飲む</h1>', back: '<p>to drink</p>')

      file_path = described_class.new(deck:).call

      expect(File).to exist(file_path)
      content = File.read(file_path)
      expect(content).to start_with('#front|back')
      expect(content).to include('<h1>食べる</h1>|<p>to eat</p>')
      expect(content).to include('<h1>飲む</h1>|<p>to drink</p>')
    end

    it 'preserves card order by position' do
      create_card(deck:, position: 2, front: '<h1>second</h1>', back: '<p>2</p>')
      create_card(deck:, position: 1, front: '<h1>first</h1>', back: '<p>1</p>')

      content = File.read(described_class.new(deck:).call)
      first_index = content.index('<h1>first</h1>')
      second_index = content.index('<h1>second</h1>')

      expect(first_index).to be < second_index
    end

    it 'raises when the deck has no cards' do
      expect do
        described_class.new(deck:).call
      end.to raise_error(DeckAnkiExportGenerator::Error, 'Deck has no cards to export')
    end
  end
end
