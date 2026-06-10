# frozen_string_literal: true

# Loads a Wiktionary JSONL extract into dictionary entry records.
class WiktionaryDictionaryImporter
  attr_accessor :entries, :file, :dictionary, :language

  def initialize
    @entries = []
  end

  def call(language:, file:)
    raise ArgumentError, 'language is required' if language.blank?
    raise ArgumentError, 'file is required' if file.blank?

    @language = language.to_s
    @file = File.new(file, 'r')
    @dictionary = Dictionary.find_or_create_for!(name: dictionary_name(file), language:)
    process_dict_entries
  ensure
    @file&.close
  end

  private

  def dictionary_name(path)
    File.basename(path, File.extname(path))
  end

  def process_dict_entries
    file.each_line do |line|
      next if line.strip.blank?

      dict_entry = JSON.parse(line)
      next unless importable?(dict_entry)

      entries << build_dictionary_entry(dict_entry)
      import_dictionary_entries if entries.length > 5_000
    end

    import_dictionary_entries
  end

  def importable?(dict_entry)
    dict_entry['lang_code'] == language && dict_entry['word'].present?
  end

  def import_dictionary_entries
    return unless entries.any?

    Dictionary::Entry.import(
      entries,
      recursive: true,
      validate: false
    )
    @entries = []
  end

  def build_dictionary_entry(dict_entry)
    formatted = WiktionaryDictionaryEntryFormatter.new(dict_entry).call
    DictionaryEntryBuilder.new(formatted, dictionary:).call
  end
end
