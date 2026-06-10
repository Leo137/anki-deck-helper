# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dictionary::Meaning, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:dictionary_entry).class_name('Dictionary::Entry') }
    it { is_expected.to belong_to(:dictionary) }
    it { is_expected.to have_many(:definitions).dependent(:destroy) }
    it { is_expected.to have_many(:fields).dependent(:destroy) }
    it { is_expected.to have_many(:misc_tags).dependent(:destroy) }
    it { is_expected.to have_many(:part_of_speeches).dependent(:destroy) }
  end

  describe '#to_s' do
    it 'renders tags and definitions as HTML' do
      meaning = create(:dictionary_meaning)
      create(:dictionary_meaning_misc_tag, dictionary_meaning: meaning, code: 'uk')
      create(:dictionary_meaning_field, dictionary_meaning: meaning, code: 'math')
      create(:dictionary_meaning_part_of_speech, dictionary_meaning: meaning, code: 'n')
      create(:dictionary_meaning_definition, dictionary_meaning: meaning, text: 'number')

      html = meaning.to_s

      expect(html).to include("<div class='tags'>uk-math-n</div>")
      expect(html).to include("<div class='definition'>* number</div>")
    end

    it 'omits the tags block when there are no tags' do
      meaning = create(:dictionary_meaning)
      create(:dictionary_meaning_definition, dictionary_meaning: meaning, text: 'plain definition')

      expect(meaning.to_s).not_to include("class='tags'")
      expect(meaning.to_s).to include('* plain definition')
    end
  end
end
