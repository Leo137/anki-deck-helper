# frozen_string_literal: true

module WordDictionaryEntries
  extend ActiveSupport::Concern

  def dictionary_kana_readings(language: :en)
    texts = dictionary_entries(language:).flat_map do |entry|
      entry.readings.select(&:is_kana?).map(&:text)
    end.uniq
    texts.join(', ').presence
  end

  def dictionary_entries(language: :en)
    dictionary_ids = self.class.dictionary_ids_for_language(language)
    self.class.entries_for_ids(dictionary_entry_ids_for_content, dictionary_ids)
  end

  def dictionary_entry_ids_for_content
    Dictionary::Entry.where(text: content).pluck(:id) +
      Dictionary::Reading.where(text: content).pluck(:dictionary_entry_id)
  end

  def merged_tags(language: :en)
    (tags.map(&:name) + dictionary_tag_labels(language:)).uniq
  end

  def dictionary_tag_labels(language: :en)
    dictionary_entries_for_tags(language:).flat_map do |entry|
      entry.meanings
           .select { |meaning| self.class.dictionary_ids_for_language(language).include?(meaning.dictionary_id) }
           .filter_map(&:cloud_tag_label)
    end.uniq
  end

  def dictionary_entries_for_tags(language: :en)
    @preloaded_dictionary_entries || dictionary_entries(language:).to_a
  end

  module ClassMethods
    def preload_dictionary_entries_for!(words, language: :en)
      words = Array(words)
      return if words.empty?

      contents = words.map(&:content)
      dictionary_ids = dictionary_ids_for_language(language)
      entries_by_text, entries_by_id = index_dictionary_entries(contents, dictionary_ids)
      reading_links = Dictionary::Reading.where(text: contents).pluck(:text, :dictionary_entry_id)
      assign_preloaded_entries(words, entries_by_text, entries_by_id, reading_links, dictionary_ids)
    end

    def dictionary_ids_for_language(language)
      Dictionary.joins(:language).where(languages: { code: language.to_s }).pluck(:id)
    end

    def entries_for_ids(entry_ids, dictionary_ids)
      Dictionary::Entry.where(id: entry_ids.uniq)
                       .includes(:readings, meanings: %i[definitions fields misc_tags part_of_speeches dictionary])
                       .order(:jmdict_id)
                       .select { |entry| entry_has_meanings_for?(entry, dictionary_ids) }
    end

    def entry_has_meanings_for?(entry, dictionary_ids)
      entry.meanings.any? { |meaning| dictionary_ids.include?(meaning.dictionary_id) }
    end

    def index_dictionary_entries(contents, dictionary_ids)
      entries = load_dictionary_entries_for(contents, dictionary_ids)
      [entries.group_by(&:text), entries.index_by(&:id)]
    end

    def assign_preloaded_entries(words, entries_by_text, entries_by_id, reading_links, dictionary_ids)
      words.each do |word|
        matched = matched_dictionary_entries(word, entries_by_text, entries_by_id, reading_links, dictionary_ids)
        word.instance_variable_set(:@preloaded_dictionary_entries, matched)
        word.instance_variable_set(:@preloaded_dictionary_language, matched.any? ? dictionary_ids : nil)
      end
    end

    def load_dictionary_entries_for(contents, dictionary_ids)
      Dictionary::Entry
        .where(text: contents)
        .or(Dictionary::Entry.where(id: Dictionary::Reading.where(text: contents).select(:dictionary_entry_id)))
        .includes(meanings: %i[misc_tags fields part_of_speeches dictionary])
        .distinct
        .select { |entry| entry_has_meanings_for?(entry, dictionary_ids) }
    end

    def matched_dictionary_entries(word, entries_by_text, entries_by_id, reading_links, dictionary_ids)
      matched = (entries_by_text[word.content] || []).dup
      reading_links.each do |text, entry_id|
        next unless text == word.content

        entry = entries_by_id[entry_id]
        matched << entry if entry
      end
      matched.uniq.select { |entry| entry_has_meanings_for?(entry, dictionary_ids) }
    end
  end
end
