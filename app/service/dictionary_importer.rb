# frozen_string_literal: true

# Loads the JMDict XML file into dictionary entry records.
class DictionaryImporter
  attr_accessor :entries

  def initialize
    @entries = []
  end

  def call
    Eiwa.parse_file('dictionaries/jmdict.xml', type: :jmdict_e) do |dict_entry|
      entries << build_dictionary_entry(dict_entry)

      import_dictionary_entries if entries.length > 5_000
    end
    import_dictionary_entries
  end

  private

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
    DictionaryEntryBuilder.new(dict_entry).call
  end
end
