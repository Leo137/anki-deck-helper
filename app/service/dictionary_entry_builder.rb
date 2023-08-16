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
    entry.readings.build(
      text: dict_reading.text,
      is_kana: dict_reading.is_kana
    )
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
      next unless dict_definition&.text&.present?

      meaning.definitions.build(text: dict_definition.text)
    end
  end

  def build_meaning_misc_tags(meaning, dict_meaning)
    dict_meaning.misc_tags.map do |dict_misc_tags|
      next unless dict_misc_tags&.code&.present?

      meaning.misc_tags.build(code: dict_misc_tags.code)
    end
  end

  def build_meaning_fields(meaning, dict_meaning)
    dict_meaning.fields.map do |dict_fields|
      next unless dict_fields&.code&.present?

      meaning.fields.build(code: dict_fields.code)
    end
  end

  def build_meaning_part_of_speech(meaning, dict_meaning)
    dict_meaning.parts_of_speech.map do |dict_pos|
      next unless dict_pos&.code&.present?

      meaning.part_of_speeches.build(code: dict_pos.code)
    end
  end
end
