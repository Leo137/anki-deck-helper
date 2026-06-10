# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Language, type: :model do
  describe 'validations' do
    subject { build(:language) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:dictionaries).dependent(:destroy) }
  end

  describe '.find_or_create_by_code!' do
    it 'finds an existing language by string code' do
      language = create(:language, code: 'en')

      expect(described_class.find_or_create_by_code!('en')).to eq(language)
    end

    it 'creates a language from a symbol code' do
      language = described_class.find_or_create_by_code!(:fr)

      expect(language.code).to eq('fr')
    end
  end
end
