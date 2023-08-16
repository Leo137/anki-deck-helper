# frozen_string_literal: true

# Transforms an JSON JMDict entry object into an Eiwa-compatible
# Openstruct
class DictionaryEntryFormatter
  attr_accessor :entry

  def initialize(entry)
    @entry = entry
    entry.deep_symbolize_keys!
  end

  def call
    OpenStruct.new(
      id:,
      text:,
      readings:,
      meanings:
    )
  end

  private

  def id
    entry[:id]
  end

  # Readings

  def text
    text_node = kanji_readings.first || kana_readings.first
    text_node.text
  end

  def readings
    kanji_readings + kana_readings
  end

  def kanji_readings
    entry[:kanji].map do |kanji|
      next unless kanji[:text]

      OpenStruct.new(
        text: kanji[:text],
        is_kana: false
      )
    end.compact
  end

  def kana_readings
    entry[:kana].map do |kana|
      next unless kana[:text]

      OpenStruct.new(
        text: kana[:text],
        is_kana: true
      )
    end.compact
  end

  # Meanings

  def meanings
    entry[:sense].map do |sense|
      build_meaning(sense)
    end
  end

  def build_meaning(sense)
    OpenStruct.new(
      definitions: build_meaning_definitions(sense),
      misc_tags: build_meaning_misc_tags(sense),
      fields: build_meaning_fields(sense),
      parts_of_speech: build_meaning_parts_of_speech(sense)
    )
  end

  def build_meaning_definitions(sense)
    sense[:gloss].map do |definition|
      next unless definition || definition[:text].present?

      OpenStruct.new(
        text: definition[:text]
      )
    end.compact
  end

  def build_meaning_misc_tags(sense)
    sense[:misc].map do |misc_tag|
      next unless misc_tag.present?

      OpenStruct.new(
        code: misc_tag
      )
    end.compact
  end

  def build_meaning_fields(sense)
    sense[:field].map do |field|
      next unless field.present?

      OpenStruct.new(
        code: field
      )
    end.compact
  end

  def build_meaning_parts_of_speech(sense)
    sense[:partOfSpeech].map do |pos|
      next unless pos.present?

      OpenStruct.new(
        code: pos
      )
    end.compact
  end
end
