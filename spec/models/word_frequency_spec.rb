# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordFrequency, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:word) }
    it { is_expected.to belong_to(:frequency_table) }
  end

  describe '#ratio_frequency' do
    it 'returns the frequency divided by the table max frequency' do
      table = create(:frequency_table, max_frequency: 200)
      word_frequency = create(:word_frequency, frequency_table: table, frequency: 50)

      expect(word_frequency.ratio_frequency).to eq(0.25)
    end

    it 'computes max frequency lazily when not cached' do
      table = create(:frequency_table, max_frequency: nil)
      create(:frequency_table_entry, frequency_table: table, frequency: 100)
      word_frequency = create(:word_frequency, frequency_table: table, frequency: 25)

      expect(word_frequency.ratio_frequency).to eq(0.25)
    end

    it 'returns Infinity when max frequency is zero' do
      table = create(:frequency_table, max_frequency: 0)
      word_frequency = build(:word_frequency, frequency_table: table, frequency: 10)

      expect(word_frequency.ratio_frequency).to eq(Float::INFINITY)
    end
  end
end
