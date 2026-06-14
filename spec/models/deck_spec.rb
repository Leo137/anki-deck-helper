# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cards).class_name('Deck::Card').dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:deck, name: 'Core') }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  describe 'card ordering' do
    it 'returns cards sorted by position' do
      deck = create(:deck)
      second = create(:deck_card, :complete, deck:, position: 2)
      first = create(:deck_card, :complete, deck:, position: 1)

      expect(deck.cards).to eq([first, second])
    end
  end
end
