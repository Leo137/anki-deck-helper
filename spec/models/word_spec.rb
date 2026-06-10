# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Word, type: :model do
  describe 'validations' do
    subject { build(:word) }

    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:content) }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:word_sets) }
    it { is_expected.to have_many(:word_frequencies).dependent(:destroy) }
    it { is_expected.to have_many(:word_tags).dependent(:destroy) }
    it { is_expected.to have_many(:frequency_tables).through(:word_frequencies) }
    it { is_expected.to have_many(:tags).through(:word_tags) }
    it { is_expected.to have_one(:dictionary_entry).class_name('Dictionary::Entry').with_foreign_key('text') }
  end

  describe '.by_frequency_table' do
    it 'returns words linked to the given frequency table' do
      table = create(:frequency_table)
      included = create(:word)
      excluded = create(:word)
      create(:word_frequency, word: included, frequency_table: table)

      expect(described_class.by_frequency_table(table)).to contain_exactly(included)
      expect(described_class.by_frequency_table(table)).not_to include(excluded)
    end
  end

  describe '.by_word_sets' do
    it 'returns words belonging to the given word sets' do
      word_set = create(:word_set)
      included = create(:word, word_sets: [word_set])
      create(:word)

      expect(described_class.by_word_sets([word_set])).to contain_exactly(included)
    end

    it 'returns no words when given an empty collection' do
      create(:word)

      expect(described_class.by_word_sets([])).to be_empty
    end
  end

  describe '.sorted_words_by_frequency_table' do
    it 'orders words by ascending frequency for the named table' do
      table = create(:frequency_table, name: 'jpdb')
      low = create(:word)
      high = create(:word)
      create(:word_frequency, word: low, frequency_table: table, frequency: 1)
      create(:word_frequency, word: high, frequency_table: table, frequency: 100)

      expect(described_class.sorted_words_by_frequency_table('jpdb')).to eq([low, high])
    end

    it 'excludes words from other frequency tables' do
      table = create(:frequency_table, name: 'jpdb')
      other_table = create(:frequency_table, name: 'bccwj')
      included = create(:word)
      excluded = create(:word)
      create(:word_frequency, word: included, frequency_table: table, frequency: 5)
      create(:word_frequency, word: excluded, frequency_table: other_table, frequency: 5)

      expect(described_class.sorted_words_by_frequency_table('jpdb')).to contain_exactly(included)
    end
  end

  describe '#tag!' do
    it 'strips the counter prefix and assigns the counter tag' do
      word = build(:word, content: '~本')

      word.tag!

      expect(word.content).to eq('本')
      expect(word.word_tags.size).to eq(1)
      expect(word.word_tags.first.tag.name).to eq('counter')
    end

    it 'reuses the existing counter tag' do
      counter_tag = create(:tag, name: 'counter')
      word = build(:word, content: '~枚')

      word.tag!

      expect(word.word_tags.map(&:tag)).to contain_exactly(counter_tag)
    end

    it 'does nothing when content does not start with ~' do
      word = build(:word, content: '本')

      word.tag!

      expect(word.content).to eq('本')
      expect(word.tags).to be_empty
    end
  end

  describe '#reading' do
    it 'returns kana when present' do
      word = build(:word, content: '食べる', kana: 'たべる')

      expect(word.reading).to eq('たべる')
    end

    it 'falls back to dictionary kana readings' do
      word = create(:word, content: '食べる', kana: nil)
      entry = create(:dictionary_entry, text: word.content)
      create(:dictionary_reading, :kana, dictionary_entry: entry, text: 'たべる')
      create(:dictionary_reading, dictionary_entry: entry, text: '食べる', is_kana: false)

      expect(word.reading).to eq('たべる')
    end

    it 'returns nil when no reading is available' do
      word = build(:word, content: 'unknown', kana: nil)

      expect(word.reading).to be_nil
    end
  end

  describe '#dictionary_kana_readings' do
    it 'joins unique kana readings from the linked dictionary entry' do
      word = create(:word, content: '見る')
      entry = create(:dictionary_entry, text: word.content)
      create(:dictionary_reading, :kana, dictionary_entry: entry, text: 'みる')
      create(:dictionary_reading, :kana, dictionary_entry: entry, text: 'みる')
      create(:dictionary_reading, dictionary_entry: entry, text: '見る', is_kana: false)

      expect(word.dictionary_kana_readings).to eq('みる')
    end
  end

  describe '#dictionary_entries' do
    it 'finds entries by word content and reading text' do
      word = create(:word, content: '見る')
      by_text = create(:dictionary_entry, text: '見る', jmdict_id: '100')
      by_reading = create(:dictionary_entry, text: '見る別', jmdict_id: '200')
      create(:dictionary_reading, dictionary_entry: by_reading, text: '見る', is_kana: false)

      expect(word.dictionary_entries).to contain_exactly(by_text, by_reading)
    end

    it 'deduplicates entries matched by both content and reading' do
      word = create(:word, content: '見る')
      entry = create(:dictionary_entry, text: '見る')
      create(:dictionary_reading, dictionary_entry: entry, text: '見る', is_kana: false)

      expect(word.dictionary_entries).to contain_exactly(entry)
    end

    it 'orders entries by jmdict_id' do
      word = create(:word, content: '見る')
      second = create(:dictionary_entry, text: '見る', jmdict_id: '200')
      first = create(:dictionary_entry, text: '見る別', jmdict_id: '100')
      create(:dictionary_reading, dictionary_entry: first, text: '見る', is_kana: false)

      expect(word.dictionary_entries.to_a).to eq([first, second])
    end
  end

  describe '#to_anki_card' do
    it 'delegates to AnkiCardGenerator' do
      word = build(:word, content: 'test')
      generator = instance_double(AnkiCardGenerator, call: { front: 'front', back: 'back' })
      allow(AnkiCardGenerator).to receive(:new).with(word).and_return(generator)

      expect(word.to_anki_card).to eq({ front: 'front', back: 'back' })
    end
  end

  describe '#to_kotoba_card' do
    it 'delegates to KotobaCardGenerator' do
      word = build(:word)
      generator = instance_double(KotobaCardGenerator, call: { card: 'kotoba' })
      allow(KotobaCardGenerator).to receive(:new).with(word).and_return(generator)

      expect(word.to_kotoba_card).to eq({ card: 'kotoba' })
    end
  end

  describe '#to_javascript_card' do
    it 'delegates to JavascriptCardGenerator' do
      word = build(:word)
      generator = instance_double(JavascriptCardGenerator, call: { card: 'js' })
      allow(JavascriptCardGenerator).to receive(:new).with(word).and_return(generator)

      expect(word.to_javascript_card).to eq({ card: 'js' })
    end
  end
end
