# frozen_string_literal: true

# Transforms a Wiktionary JSONL entry object into an Eiwa-compatible OpenStruct.
class WiktionaryDictionaryEntryFormatter
  attr_accessor :entry

  def initialize(entry)
    @entry = entry
    entry.deep_symbolize_keys!
  end

  def call
    OpenStruct.new(
      id: nil,
      text:,
      readings:,
      meanings:
    )
  end

  private

  def text
    entry[:word]
  end

  def readings
    transliteration_forms.map do |form|
      OpenStruct.new(
        text: form[:form],
        is_kana: kana?(form[:form])
      )
    end.uniq(&:text)
  end

  def transliteration_forms
    Array(entry[:forms]).select do |form|
      Array(form[:tags]).include?('transliteration') && form[:form].present?
    end
  end

  def kana?(text)
    text.match?(/\A[\p{Hiragana}\p{Katakana}ー\-]+\z/)
  end

  def meanings
    Array(entry[:senses]).map do |sense|
      build_meaning(sense)
    end
  end

  def build_meaning(sense)
    OpenStruct.new(
      definitions: build_meaning_definitions(sense),
      misc_tags: build_meaning_misc_tags(sense),
      fields: build_meaning_fields(sense),
      parts_of_speech: build_meaning_parts_of_speech
    )
  end

  def build_meaning_definitions(sense)
    Array(sense[:glosses]).filter_map do |gloss|
      next if gloss.blank?

      OpenStruct.new(text: gloss)
    end
  end

  def build_meaning_misc_tags(sense)
    (entry_categories + sense_categories(sense) + sense_tags(sense)).uniq.map do |code|
      OpenStruct.new(code:)
    end
  end

  def entry_categories
    Array(entry[:categories]).compact
  end

  def sense_categories(sense)
    Array(sense[:categories]).compact
  end

  def sense_tags(sense)
    Array(sense[:tags]).compact + Array(sense[:raw_tags]).compact
  end

  def build_meaning_fields(sense)
    Array(sense[:topics]).compact.map do |topic|
      OpenStruct.new(code: topic)
    end
  end

  def build_meaning_parts_of_speech
    return [] if entry[:pos].blank?

    [OpenStruct.new(code: entry[:pos])]
  end
end
