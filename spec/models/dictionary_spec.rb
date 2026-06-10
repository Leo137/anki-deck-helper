# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dictionary, type: :model do
  describe 'validations' do
    subject { build(:dictionary) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:language_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:language) }
    it { is_expected.to have_many(:meanings).class_name('Dictionary::Meaning').dependent(:destroy) }
  end

  describe '.find_or_create_for!' do
    it 'creates a dictionary for the given name and language' do
      dictionary = described_class.find_or_create_for!(name: 'jmdict-eng-3.5.0', language: :en)

      expect(dictionary.name).to eq('jmdict-eng-3.5.0')
      expect(dictionary.language.code).to eq('en')
    end

    it 'reuses an existing dictionary for the same name and language' do
      existing = described_class.find_or_create_for!(name: 'jmdict-eng-3.5.0', language: :en)

      expect(described_class.find_or_create_for!(name: 'jmdict-eng-3.5.0', language: :en)).to eq(existing)
    end
  end
end
