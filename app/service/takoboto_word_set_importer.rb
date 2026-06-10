# frozen_string_literal: true

require 'csv'

# Imports word sets from a Takoboto CSV export.
# Each distinct List value becomes its own WordSet (origin: takoboto).
# Only the Word column is stored; kanji forms are preferred over kana readings.
# Translations are ignored.
class TakobotoWordSetImporter
  attr_accessor :filepath, :word_sets

  def initialize(filepath)
    @filepath = filepath
    @word_sets = {}
  end

  def call
    CSV.foreach(filepath, headers: true, encoding: 'bom|utf-8') do |row|
      import_row(row)
    end
  end

  private

  def import_row(row)
    list_name = column_value(row, 'List')
    return if list_name.blank?

    word_set = word_set_for(list_name)
    content = extract_word_content(column_value(row, 'Word'))
    return if content.blank?

    word = Word.find_or_create_by(content:)
    word.word_sets << word_set
    word.tag!
    word.word_count += 1
    word.save
  end

  def word_set_for(list_name)
    name = list_name.strip
    word_sets[name] ||= WordSet.find_or_create_by!(name:, origin: :takoboto)
  end

  def column_value(row, column)
    header = row.headers.find { |h| normalize_header(h) == column }
    return unless header

    row[header]&.strip
  end

  def normalize_header(header)
    header.to_s.delete_prefix("\uFEFF").strip
  end

  def extract_word_content(word_field)
    parts = word_field.to_s.split(',').map(&:strip).reject(&:empty?)
    return if parts.empty?

    kanji_form = parts.find { |part| contains_kanji?(part) }
    return kanji_form if kanji_form

    parts.length > 1 ? parts[1] : parts.first
  end

  def contains_kanji?(text)
    text.match?(/\p{Han}/)
  end
end
