# frozen_string_literal: true

require 'csv'

# Imports word sets from a Takoboto CSV export.
# Each distinct List value becomes its own WordSet (origin: takoboto).
# Only the first reading from the Word column is stored; translations are ignored.
class TakobotoWordSetImporter
  attr_accessor :file, :word_sets

  def initialize(filepath)
    @file = File.new(filepath, 'r')
    @word_sets = {}
  end

  def call
    CSV.foreach(file, headers: true) do |row|
      import_row(row)
    end
  ensure
    file.close
  end

  private

  def import_row(row)
    word_set = word_set_for(row['List'])
    content = extract_first_reading(row['Word'])
    return if content.blank?

    word = Word.find_or_create_by(content:)
    word.word_sets << word_set
    word.tag!
    word.word_count += 1
    word.save
  end

  def word_set_for(list_name)
    name = list_name.to_s.strip
    word_sets[name] ||= WordSet.find_or_create_by!(name:, origin: :takoboto)
  end

  def extract_first_reading(word_field)
    parts = word_field.to_s.split(',').map(&:strip).reject(&:empty?)
    return if parts.empty?

    parts.length > 1 ? parts[1] : parts.first
  end
end
