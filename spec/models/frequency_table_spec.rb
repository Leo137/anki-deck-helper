# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrequencyTable, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:word_frequencies) }
    it { is_expected.to have_many(:frequency_table_entries) }
  end

  describe '#max_frequency' do
    it 'returns the cached value when already set' do
      table = create(:frequency_table, max_frequency: 42)
      create(:frequency_table_entry, frequency_table: table, frequency: 100)

      expect(table.max_frequency).to eq(42)
    end

    it 'computes and persists max frequency from entries when unset' do
      table = create(:frequency_table, max_frequency: nil)
      create(:frequency_table_entry, frequency_table: table, frequency: 10)
      create(:frequency_table_entry, frequency_table: table, frequency: 50)

      expect(table.max_frequency).to eq(50)
      expect(table.reload.read_attribute(:max_frequency)).to eq(50)
    end

    it 'returns 0 when there are no entries and no cached value' do
      table = create(:frequency_table, max_frequency: nil)

      expect(table.max_frequency).to eq(0)
    end
  end
end
