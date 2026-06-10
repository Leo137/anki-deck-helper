# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:deck_words).dependent(:destroy) }
    it { is_expected.to have_many(:words).through(:deck_words) }
  end

  describe 'validations' do
    subject { build(:deck, name: 'Core') }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  describe 'word ordering' do
    it 'returns words sorted by position' do
      deck = create(:deck)
      first_word = create(:word, content: 'alpha')
      second_word = create(:word, content: 'beta')
      deck.deck_words.create!(word: second_word, position: 2)
      deck.deck_words.create!(word: first_word, position: 1)

      expect(deck.words.pluck(:content)).to eq(%w[alpha beta])
    end
  end
end
