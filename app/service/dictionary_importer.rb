# frozen_string_literal: true

# Loads the JMDict JSON file into dictionary entry records.
class DictionaryImporter
  attr_accessor :entries, :file, :dictionary

  def initialize
    @entries = []
  end

  def call(language:, file:)
    raise ArgumentError, 'language is required' if language.blank?
    raise ArgumentError, 'file is required' if file.blank?

    @file = File.new(file, 'r')
    @dictionary = Dictionary.find_or_create_for!(name: dictionary_name(file), language:)
    process_dict_entries(json_data['words'])
  ensure
    file&.close
  end

  private

  def dictionary_name(path)
    File.basename(path, '.json')
  end

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
      entries,
      recursive: true,
      validate: false
    )
    @entries = []
  end

  def build_dictionary_entry(dict_entry)
    formatted = DictionaryEntryFormatter.new(dict_entry).call
    DictionaryEntryBuilder.new(formatted, dictionary:).call
  end

  def json_data
    @json_data ||= build_json_data
  end

  def build_json_data
    parser = Yajl::Parser.new
    parser.parse(file)
  end
end
