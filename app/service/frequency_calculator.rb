# frozen_string_literal: true

# Given a list of words and a frequency table, looks up the frequency for each word
class FrequencyCalculator
  attr_accessor :frequency_table, :words, :word_frequencies

  def initialize(frequency_table_name, words)
    @frequency_table = FrequencyTable.find_by!(name: frequency_table_name)
    @words = words
    @word_frequencies = []
  end

  def call
    words.find_each do |word|
      next unless word.content
      next unless (frequency = find_word_frequency(word.content))

      word_frequencies << WordFrequency.new(
        frequency: frequency.frequency,
        word:,
        frequency_table:
      )
      import_word_frequencies if word_frequencies.length > 1_000
    end
    import_word_frequencies
  end

  private

  def import_word_frequencies
    return unless word_frequencies.any?

    WordFrequency.import(
      word_frequencies.uniq,
      on_duplicate_key_update: { conflict_target: [:word_id, :frequency_table_id], columns: [:frequency] },
      recursive: true
    )
    @word_frequencies = []
  end

  def find_word_frequency(content)
    FrequencyTableEntry.find_by(
      frequency_table:,
      content:
    )
  end
end
