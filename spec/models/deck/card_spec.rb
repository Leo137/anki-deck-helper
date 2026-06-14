# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Card, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:deck) }
    it { is_expected.to have_many(:fields).class_name('Deck::Card::Field').dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:deck_card, deck: create(:deck)) }

    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_uniqueness_of(:position).scoped_to(:deck_id) }

    it 'requires front and back fields' do
      card = build(:deck_card)
      card.fields.build(side: :front, html_content: '<h1>ふもと</h1>')

      expect(card).not_to be_valid
      expect(card.errors[:fields]).to include('must include front and back')
    end

    it 'is valid with front and back fields' do
      card = build(:deck_card)
      card.fields.build(side: :front, html_content: '<h1>ふもと</h1>')
      card.fields.build(side: :back, html_content: '<div class="definition">* foot</div>')

      expect(card).to be_valid
    end
  end

  describe '#front_field and #back_field' do
    it 'returns the matching field records' do
      card = create(:deck_card, :complete)

      expect(card.front_field).to be_front
      expect(card.front_field.html_content).to eq('<h1>ふもと</h1>')
      expect(card.back_field).to be_back
      expect(card.back_field.html_content).to include('class="definition"')
    end
  end
end
