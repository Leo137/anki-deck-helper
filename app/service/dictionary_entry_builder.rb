# frozen_string_literal: true

# Builds an Eiwa entry into a Dictionary::Entry record.
# Doesnt persist it
class DictionaryEntryBuilder
  attr_accessor :dict_entry, :entry

  def initialize(dict_entry)
    @dict_entry = dict_entry
  end

  def call
    @entry = Dictionary::Entry.new(text: dict_entry.text)

    build_dictionary_meanings
    build_dictionary_readings

    entry
  end

  private

  def build_dictionary_readings
    dict_entry.readings.map do |dict_readings|
      build_dictionary_reading(dict_readings)
    end
  end

  def build_dictionary_reading(dict_reading)
    entry.readings.build(text: dict_reading.text)
  end

  # Process Meanings

  def build_dictionary_meanings
    dict_entry.meanings.map do |dict_meaning|
      build_dictionary_meaning(dict_meaning)
    end
  end

  def build_dictionary_meaning(dict_meaning)
    entry.meanings.build do |meaning|
      build_meaning_definitions(meaning, dict_meaning)
      build_meaning_misc_tags(meaning, dict_meaning)
      build_meaning_fields(meaning, dict_meaning)
      build_meaning_part_of_speech(meaning, dict_meaning)
    end
  end

  def build_meaning_definitions(meaning, dict_meaning)
    dict_meaning.definitions.map do |dict_definition|
      meaning.definitions.new(text: dict_definition.text)
    end
  end

  def build_meaning_misc_tags(meaning, dict_meaning)
    dict_meaning.misc_tags.map do |dict_misc_tags|
      meaning.misc_tags.new(code: dict_misc_tags.code)
    end
  end

  def build_meaning_fields(meaning, dict_meaning)
    dict_meaning.fields.map do |dict_fields|
      meaning.fields.new(code: dict_fields.code)
    end
  end

  def build_meaning_part_of_speech(meaning, dict_meaning)
    dict_meaning.parts_of_speech.map do |dict_pos|
      meaning.part_of_speeches.new(code: dict_pos.code)
    end
  end
end
