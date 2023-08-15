# frozen_string_literal: true

# Opens a file in which every line is a word to insert.
# Creates/Updates Word set with Word records for each line
class WordSetImporter
  attr_accessor :word_set, :file, :words

  def initialize(word_set_name, filepath)
    @word_set = WordSet.find_or_create_by(name: word_set_name)
    @words = []
    @file = File.new(filepath, 'r')
  end

  def call
    file.each_line do |term|
      next unless term


      word = Word.find_or_create_by(content: clean_content(term))
      word.word_sets.build(word_set:)
      word.tag!
      words << word
      import_words if words.length > 1_000
    end
    import_words
  ensure
    file.close
  end

  private

  def import_words
    return unless words.any?

    Word.import(
      words.uniq(&:content),
      validate_uniqueness: true,
      recursive: true
    )
    @words = []
  end

  def clean_content(content)
    content.strip
  end
end
