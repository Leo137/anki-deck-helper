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
      word.word_sets << word_set
      word.tag!
      word.word_count += 1
      word.save
    end
  ensure
    file.close
  end

  private

  def clean_content(content)
    content.strip
  end
end
