# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Card::Field, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:card).class_name('Deck::Card') }
  end

  describe 'validations' do
    subject { build(:deck_card_field, :front, card: create(:deck_card, :complete)) }

    it { is_expected.to validate_presence_of(:side) }
    it { is_expected.to validate_presence_of(:html_content) }

    it 'allows only one field per side on a card' do
      card = create(:deck_card, :complete)
      duplicate = build(:deck_card_field, :front, card:)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:side]).to include('has already been taken')
    end
  end

  describe 'sides' do
    it 'stores HTML content for front and back' do
      card = create(:deck_card, :complete)

      expect(card.front_field).to be_front
      expect(card.front_field.html_content).to eq('<h1>ふもと</h1>')
      expect(card.back_field).to be_back
      expect(card.back_field.html_content).to include('<div class="reading">ふもと</div>')
      expect(card.back_field.html_content).to include('* foot (of a mountain or hill)')
    end
  end
end
