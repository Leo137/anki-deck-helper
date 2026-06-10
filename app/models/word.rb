class Word < ApplicationRecord
  validates :content, presence: true, uniqueness: true

  has_and_belongs_to_many :word_sets
  has_many :word_frequencies, dependent: :destroy
  has_many :word_tags, dependent: :destroy
  has_many :frequency_tables, through: :word_frequencies
  has_many :tags, through: :word_tags
  has_one :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'text', primary_key: 'content',
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
    if content[/^~/]
      # Word is a counter
      word_tags.build(tag: Tag.find_or_create_by(name: 'counter'))
      content.gsub!('~', '')
    end
  end

  def self.sorted_words_by_frequency_table(name)
    joins(word_frequencies: :frequency_table)
      .where(frequency_table: { name: })
      .order('word_frequencies.frequency ASC')
  end

  def reading
    kana.presence || dictionary_kana_readings
  end

  def dictionary_kana_readings
    dictionary_entry&.readings&.select(&:is_kana?)&.map(&:text)&.uniq&.join(', ').presence
  end

  def dictionary_entries
    entry_ids = Dictionary::Entry.where(text: content).pluck(:id)
    entry_ids += Dictionary::Reading.where(text: content).pluck(:dictionary_entry_id)

    Dictionary::Entry.where(id: entry_ids.uniq)
                     .includes(:readings, meanings: %i[definitions fields misc_tags part_of_speeches])
                     .order(:jmdict_id)
  end

  def merged_tags
    (tags.map(&:name) + dictionary_tag_labels).uniq
  end

  def dictionary_tag_labels
    dictionary_entries_for_tags.flat_map do |entry|
      entry.meanings.filter_map(&:cloud_tag_label)
    end.uniq
  end

  def self.preload_dictionary_entries_for!(words)
    words = Array(words)
    return if words.empty?

    contents = words.map(&:content)
    entries = Dictionary::Entry
              .where(text: contents)
              .or(Dictionary::Entry.where(id: Dictionary::Reading.where(text: contents).select(:dictionary_entry_id)))
              .includes(meanings: %i[misc_tags fields part_of_speeches])
              .distinct
              .to_a

    entries_by_text = entries.group_by(&:text)
    entries_by_id = entries.index_by(&:id)
    reading_links = Dictionary::Reading.where(text: contents).pluck(:text, :dictionary_entry_id)

    words.each do |word|
      matched = (entries_by_text[word.content] || []).dup
      reading_links.each do |text, entry_id|
        matched << entries_by_id[entry_id] if text == word.content && entries_by_id[entry_id]
      end
      word.instance_variable_set(:@preloaded_dictionary_entries, matched.uniq)
    end
  end

  def dictionary_entries_for_tags
    @preloaded_dictionary_entries || dictionary_entries.to_a
  end

  def to_anki_card
    AnkiCardGenerator.new(self).call
  end

  def to_kotoba_card
    KotobaCardGenerator.new(self).call
  end

  def to_javascript_card
    JavascriptCardGenerator.new(self).call
  end
end
