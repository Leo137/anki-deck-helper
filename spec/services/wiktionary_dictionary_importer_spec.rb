# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WiktionaryDictionaryImporter do
  let(:fixture_path) { Rails.root.join('spec/fixtures/files/wiktionary_densha.jsonl') }

  describe '#call' do
    it 'imports Japanese entries from a JSONL file' do
      described_class.new.call(language: :ja, file: fixture_path)

      dictionary = Dictionary.find_by!(name: 'wiktionary_densha', language: Language.find_by!(code: 'ja'))
      entry = Dictionary::Entry.find_by!(text: '電車')

      expect(entry.readings.pluck(:text, :is_kana)).to eq([['でんしゃ', true]])
      expect(entry.meanings.where(dictionary:).count).to eq(4)
    end

    it 'persists definitions, part of speech, and misc tags' do
      described_class.new.call(language: :ja, file: fixture_path)

      dictionary = Dictionary.find_by!(name: 'wiktionary_densha', language: Language.find_by!(code: 'ja'))
      entry = Dictionary::Entry.find_by!(text: '電車')
      first_meaning = entry.meanings.where(dictionary:).order(:id).first

      expect(first_meaning.definitions.pluck(:text)).to eq([
        '外部からの電気を動力として走る列車のうち、1編成中の車両のいくつか又はすべてに動力となる電動機を装備して自走能力をそなえ、機関車の牽引によらずに走行する列車。'
      ])
      expect(first_meaning.part_of_speeches.pluck(:code)).to eq(['noun'])
      expect(first_meaning.misc_tags.pluck(:code)).to include('和製漢語', '日本語 鉄道', '車両')
      expect(first_meaning.fields.pluck(:code)).to eq(['rail-transport'])
    end

    it 'skips entries that do not match the requested language' do
      described_class.new.call(language: :ja, file: fixture_path)

      expect(Dictionary::Entry.find_by(text: 'train')).to be_nil
    end

    it 'raises when language is missing' do
      expect { described_class.new.call(language: nil, file: fixture_path) }
        .to raise_error(ArgumentError, 'language is required')
    end

    it 'raises when file is missing' do
      expect { described_class.new.call(language: :ja, file: nil) }
        .to raise_error(ArgumentError, 'file is required')
    end
  end
end
