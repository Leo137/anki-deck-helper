# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dictionary::Entry, type: :model do
  describe 'validations' do
    subject { build(:dictionary_entry) }

    it { is_expected.to validate_presence_of(:text) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:meanings).class_name('Dictionary::Meaning').dependent(:destroy) }
    it { is_expected.to have_many(:readings).class_name('Dictionary::Reading').dependent(:destroy) }
  end

  describe '#to_s' do
    it 'renders kana readings and meanings as HTML' do
      entry = create(:dictionary_entry, text: '食べる')
      create(:dictionary_reading, :kana, dictionary_entry: entry, text: 'たべる')
      meaning = create(:dictionary_meaning, dictionary_entry: entry, dictionary: create(:dictionary, :english_jmdict))
      create(:dictionary_meaning_definition, dictionary_meaning: meaning, text: 'to eat')

      html = entry.to_s

      expect(html).to include("<div class='reading'>たべる</div>")
      expect(html).to include("<div class='definition'>* to eat</div>")
      expect(html).to include('<hr>')
    end

    it 'omits non-kana readings from the reading block' do
      entry = create(:dictionary_entry)
      create(:dictionary_reading, dictionary_entry: entry, text: 'kanji', is_kana: false)

      expect(entry.to_s).not_to include('kanji')
    end
  end
end
