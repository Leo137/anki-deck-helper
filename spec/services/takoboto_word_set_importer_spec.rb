# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TakobotoWordSetImporter do
  let(:csv_path) { Rails.root.join('spec/fixtures/files/takoboto_sample.csv') }

  describe '#call' do
    it 'creates a separate takoboto word set for each list' do
      described_class.new(csv_path).call

      favorites = WordSet.find_by!(name: 'Favorites', origin: :takoboto)
      history = WordSet.find_by!(name: 'History', origin: :takoboto)

      expect(favorites.words.pluck(:content)).to contain_exactly('こしつ', 'ちんたいじゅうたく')
      expect(history.words.pluck(:content)).to contain_exactly('きたいかん', 'たさい')
    end

    it 'stores only the first reading from the Word column' do
      described_class.new(csv_path).call

      expect(Word.find_by!(content: 'こしつ')).to be_present
      expect(Word.find_by(content: '固執')).to be_nil
      expect(Word.find_by(content: 'こしゅう')).to be_nil
    end

    it 'does not modify a normal word set with the same name' do
      normal_set = create(:word_set, name: 'Favorites', origin: :normal)
      normal_word = create(:word, content: 'existing')
      normal_set.words << normal_word

      described_class.new(csv_path).call

      normal_set.reload
      takoboto_set = WordSet.find_by!(name: 'Favorites', origin: :takoboto)

      expect(normal_set.words).to contain_exactly(normal_word)
      expect(takoboto_set.words.pluck(:content)).to contain_exactly('こしつ', 'ちんたいじゅうたく')
    end

    it 'reuses the takoboto word set on subsequent imports' do
      described_class.new(csv_path).call
      first_set = WordSet.find_by!(name: 'History', origin: :takoboto)

      described_class.new(csv_path).call
      second_set = WordSet.find_by!(name: 'History', origin: :takoboto)

      expect(second_set.id).to eq(first_set.id)
      expect(WordSet.where(name: 'History', origin: :takoboto).count).to eq(1)
      expect(Word.find_by!(content: 'きたいかん').word_count).to eq(2)
    end
  end

  describe '#extract_first_reading' do
    let(:importer) { described_class.new(csv_path) }

    it 'returns the first reading when multiple comma-separated values are present' do
      expect(importer.send(:extract_first_reading, '固執, こしつ, こしゅう')).to eq('こしつ')
    end

    it 'returns the sole value when no reading is present' do
      expect(importer.send(:extract_first_reading, '単語')).to eq('単語')
    end
  end
end
