# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckWord, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:deck) }
    it { is_expected.to belong_to(:word) }
  end

  describe 'validations' do
    subject { build(:deck_word) }

    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_uniqueness_of(:position).scoped_to(:deck_id) }
    it { is_expected.to validate_uniqueness_of(:word_id).scoped_to(:deck_id) }
  end
end
