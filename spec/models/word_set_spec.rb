# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordSet, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:words) }
  end

  describe 'validations' do
    subject { build(:word_set, name: 'shared-name') }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:origin) }
  end

  describe 'origin' do
    it 'defaults to normal' do
      word_set = create(:word_set)

      expect(word_set).to be_normal
    end

    it 'allows the same name for different origins' do
      create(:word_set, name: 'Favorites', origin: :normal)
      takoboto_set = create(:word_set, :takoboto, name: 'Favorites')

      expect(takoboto_set).to be_takoboto
      expect(described_class.where(name: 'Favorites').count).to eq(2)
    end
  end

  describe '.ransackable_attributes' do
    it 'allows searching by name and origin' do
      expect(described_class.ransackable_attributes).to include('name', 'origin')
    end
  end
end
