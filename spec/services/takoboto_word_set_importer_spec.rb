# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TakobotoWordSetImporter do
  let(:csv_path) { Rails.root.join('spec/fixtures/files/takoboto_sample.csv') }

  describe '#call' do
    it 'creates a separate takoboto word set for each list' do
      described_class.new(csv_path).call

      favorites = WordSet.find_by!(name: 'Favorites', origin: :takoboto)
      history = WordSet.find_by!(name: 'History', origin: :takoboto)

      expect(favorites.words.pluck(:content)).to contain_exactly('固執', '賃貸住宅')
      expect(history.words.pluck(:content)).to contain_exactly('期待感', '多彩')
    end

    it 'prefers kanji forms from the Word column' do
      described_class.new(csv_path).call

      expect(Word.find_by!(content: '固執')).to be_present
      expect(Word.find_by(content: 'こしつ')).to be_nil
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
      expect(takoboto_set.words.pluck(:content)).to contain_exactly('固執', '賃貸住宅')
    end

    it 'reads list names from CSV files with a UTF-8 BOM' do
      described_class.new(Rails.root.join('spec/fixtures/files/takoboto_sample_bom.csv')).call

      favorites = WordSet.find_by!(name: 'Favorites', origin: :takoboto)
      history = WordSet.find_by!(name: 'History', origin: :takoboto)

      expect(favorites.words.pluck(:content)).to eq(['固執'])
      expect(history.words.pluck(:content)).to eq(['期待感'])
      expect(WordSet.where(name: '', origin: :takoboto)).to be_empty
    end

    it 'reuses the takoboto word set on subsequent imports' do
      described_class.new(csv_path).call
      first_set = WordSet.find_by!(name: 'History', origin: :takoboto)

      described_class.new(csv_path).call
      second_set = WordSet.find_by!(name: 'History', origin: :takoboto)

      expect(second_set.id).to eq(first_set.id)
      expect(WordSet.where(name: 'History', origin: :takoboto).count).to eq(1)
      expect(Word.find_by!(content: '期待感').word_count).to eq(2)
    end
  end

  describe '#extract_word_content' do
    let(:importer) { described_class.new(csv_path) }

    it 'returns the first kanji form when one is present' do
      expect(importer.send(:extract_word_content, '固執, こしつ, こしゅう')).to eq('固執')
      expect(importer.send(:extract_word_content, '依存度, いぞんど')).to eq('依存度')
    end

    it 'returns the first reading when no kanji form is present' do
      expect(importer.send(:extract_word_content, 'アオハル, あおはる')).to eq('あおはる')
    end

    it 'returns the sole value when only one segment is present' do
      expect(importer.send(:extract_word_content, '単語')).to eq('単語')
    end
  end
end
