# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrequencyTableEntry, type: :model do
  describe 'validations' do
    subject { build(:frequency_table_entry) }

    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:content).scoped_to(:frequency_table_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:frequency_table) }
  end

  describe 'scoped uniqueness' do
    it 'allows the same content in different frequency tables' do
      first_table = create(:frequency_table)
      second_table = create(:frequency_table)
      create(:frequency_table_entry, frequency_table: first_table, content: 'duplicate')

      duplicate = build(:frequency_table_entry, frequency_table: second_table, content: 'duplicate')

      expect(duplicate).to be_valid
    end

    it 'rejects duplicate content within the same frequency table' do
      table = create(:frequency_table)
      create(:frequency_table_entry, frequency_table: table, content: 'duplicate')

      duplicate = build(:frequency_table_entry, frequency_table: table, content: 'duplicate')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:content]).to include('has already been taken')
    end
  end
end
