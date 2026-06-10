# frozen_string_literal: true

class Word < ApplicationRecord
  validates :content, presence: true, uniqueness: true

  has_and_belongs_to_many :word_sets
  has_many :word_frequencies, dependent: :destroy
  has_many :word_tags, dependent: :destroy
  has_many :frequency_tables, through: :word_frequencies
  has_many :tags, through: :word_tags
  has_many :dictionary_entries, class_name: 'Dictionary::Entry', foreign_key: 'text', primary_key: 'content',
                                inverse_of: false, dependent: nil

  scope :frequency_ordered, -> { includes(:word_frequencies).order('word_frequencies.frequency') }

  def self.ransackable_attributes(_auth_object = nil)
    %w[content kana]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.by_frequency_table(frequency_table)
    includes(:word_frequencies)
      .where(word_frequencies: { frequency_table: })
  end

  def self.by_word_sets(word_sets)
    includes(:word_sets)
      .where(word_sets: { id: word_sets.pluck(:id) })
  end

  def tag!
    return unless content[/^~/]

    # Word is a counter
    word_tags.build(tag: Tag.find_or_create_by(name: 'counter'))
    content.gsub!('~', '')
  end

  def self.sorted_words_by_frequency_table(name)
    joins(word_frequencies: :frequency_table)
      .where(frequency_table: { name: })
      .order('word_frequencies.frequency ASC')
  end

  def reading(language: :en)
    kana.presence || dictionary_kana_readings(language:)
  end

  def dictionary_kana_readings(language: :en)
    texts = dictionary_entries(language:).flat_map do |entry|
      entry.readings.select(&:is_kana?).map(&:text)
    end.uniq
    texts.join(', ').presence
  end

  def dictionary_entries(language: :en)
    entry_ids = Dictionary::Entry.where(text: content).pluck(:id)
    entry_ids += Dictionary::Reading.where(text: content).pluck(:dictionary_entry_id)
    dictionary_ids = self.class.dictionary_ids_for_language(language)

    Dictionary::Entry.where(id: entry_ids.uniq)
                     .includes(:readings, meanings: %i[definitions fields misc_tags part_of_speeches dictionary])
                     .order(:jmdict_id)
                     .select { |entry| entry.meanings.any? { |meaning| dictionary_ids.include?(meaning.dictionary_id) } }
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

  def self.preload_dictionary_entries_for!(words, language: :en)
    words = Array(words)
    return if words.empty?

    contents = words.map(&:content)
    dictionary_ids = dictionary_ids_for_language(language)
    entries_by_text, entries_by_id = index_dictionary_entries(contents, dictionary_ids)
    reading_links = Dictionary::Reading.where(text: contents).pluck(:text, :dictionary_entry_id)
    assign_preloaded_entries(words, entries_by_text, entries_by_id, reading_links, dictionary_ids)
  end

  def self.dictionary_ids_for_language(language)
    Dictionary.joins(:language).where(languages: { code: language.to_s }).pluck(:id)
  end

  def self.index_dictionary_entries(contents, dictionary_ids)
    entries = load_dictionary_entries_for(contents, dictionary_ids)
    [entries.group_by(&:text), entries.index_by(&:id)]
  end

  def self.assign_preloaded_entries(words, entries_by_text, entries_by_id, reading_links, dictionary_ids)
    words.each do |word|
      matched = matched_dictionary_entries(word, entries_by_text, entries_by_id, reading_links, dictionary_ids)
      word.instance_variable_set(:@preloaded_dictionary_entries, matched)
      word.instance_variable_set(:@preloaded_dictionary_language, matched.any? ? dictionary_ids : nil)
    end
  end

  def self.load_dictionary_entries_for(contents, dictionary_ids)
    Dictionary::Entry
      .where(text: contents)
      .or(Dictionary::Entry.where(id: Dictionary::Reading.where(text: contents).select(:dictionary_entry_id)))
      .includes(meanings: %i[misc_tags fields part_of_speeches dictionary])
      .distinct
      .select { |entry| entry.meanings.any? { |meaning| dictionary_ids.include?(meaning.dictionary_id) } }
  end

  def self.matched_dictionary_entries(word, entries_by_text, entries_by_id, reading_links, dictionary_ids)
    matched = (entries_by_text[word.content] || []).dup
    reading_links.each do |text, entry_id|
      next unless text == word.content

      entry = entries_by_id[entry_id]
      matched << entry if entry
    end
    matched.uniq.select { |entry| entry.meanings.any? { |m| dictionary_ids.include?(m.dictionary_id) } }
  end

  def dictionary_entries_for_tags(language: :en)
    @preloaded_dictionary_entries || dictionary_entries(language:).to_a
  end

  def to_anki_card(dictionary:)
    AnkiCardGenerator.new(self, dictionary:).call
  end

  def to_kotoba_card(dictionary:)
    KotobaCardGenerator.new(self, dictionary:).call
  end

  def to_javascript_card(dictionary:)
    JavascriptCardGenerator.new(self, dictionary:).call
  end
end
