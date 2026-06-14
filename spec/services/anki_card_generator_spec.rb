# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnkiCardGenerator do
  let!(:language) { create(:language, :english) }
  let!(:dictionary) { create(:dictionary, language:, name: 'jmdict-eng-3.5.0') }
  let!(:word) { create(:word, content: '増える') }

  describe '#generate_back' do
    it 'sorts dictionary entries when some have a nil jmdict_id' do
      entry_with_id = create(:dictionary_entry, text: '増える', jmdict_id: 42)
      create(:dictionary_entry, text: '増える', jmdict_id: nil)
      meaning = create(:dictionary_meaning, dictionary_entry: entry_with_id, dictionary:)
      create(:dictionary_meaning_definition, dictionary_meaning: meaning, text: 'to increase')

      generator = described_class.new(word, dictionary:)

      expect { generator.generate_back }.not_to raise_error
      expect(generator.generate_back).to include('to increase')
    end
  end
end
