# frozen_string_literal: true

# Estimates the importance of learning some words based on 1 or more frequency tables
class WordPriorityEstimator
  attr_accessor :words, :frequency_tables

  def initialize(words, frequency_tables)
    @words = words
    @frequency_tables = frequency_tables
  end

  def call
    word_objects.sort_by { |word| word.priorities.priority }.reverse
  end

  private

  def word_objects
    @word_objects ||= words.find_each.map { |word| build_word_object(word) }
  end

  def build_word_object(word)
    OpenStruct.new(
      word:,
      priorities: calculate_priorities(word)
    )
  end

  def calculate_priorities(word)
    frequency_priority = calculate_frequency_priority(word)
    word_count_priority = calculate_word_count_priority(word)
    priority = (frequency_priority * 0.92) + (word_count_priority * 0.08)

    OpenStruct.new(
      frequency_priority:,
      word_count_priority:,
      priority:
    )
  end

  def calculate_frequency_priority(word)
    # Calculate priority based on frequencies
    frequencies = find_word_frequencies(word)
    return 0 unless frequencies.any?

    1 - ((frequencies.sum(&:ratio_frequency) || 0) / frequencies.size.to_f)
  end

  def calculate_word_count_priority(word)
    # Calculate priority based on number of word appearances
    word.word_count.to_i.clamp(0, 3) / 3.0
  end

  def find_word_frequencies(word)
    word
      .word_frequencies
      .includes(:frequency_table)
      .where(frequency_table: frequency_tables)
  end
end
