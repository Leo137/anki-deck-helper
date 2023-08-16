# frozen_string_literal: true

# Loads the JMDict XML file into dictionary entry records.
class DictionaryImporter
  attr_accessor :entries, :file

  def initialize
    @entries = []
    @file = File.new('dictionaries/jmdict-eng-3.5.0.json', 'r')
  end

  def call
    # Skip the 6 first records, those are metadata.
    process_dict_entries(json_data['words'])
  ensure
    file.close
  end

  private

  def process_dict_entries(dict_entries)
    dict_entries.each do |dict_entry|
      entries << build_dictionary_entry(dict_entry)
      import_dictionary_entries if entries.length > 5_000
    end

    import_dictionary_entries
  end

  def import_dictionary_entries
    return unless entries.any?

    Dictionary::Entry.import(
      entries.uniq(&:text),
      recursive: true,
      validate: false,
      on_duplicate_key_update: { conflict_target: [:text], columns: [] }
    )
    @entries = []
  end

  def build_dictionary_entry(dict_entry)
    formatted = DictionaryEntryFormatter.new(dict_entry).call
    DictionaryEntryBuilder.new(formatted).call
  end

  def json_data
    @json_data ||= build_json_data
  end

  def build_json_data
    parser = Yajl::Parser.new
    parser.parse(file)
  end
end
