# frozen_string_literal: true

# Given a word set and a frequency table, looks up the frequency for each word
class FrequencyCalculator
  attr_accessor :frequency_table, :word_set, :word_frequencies

  def initialize(frequency_table_name, word_set_name)
    @frequency_table = FrequencyTable.find_by!(name: frequency_table_name)
    @word_set = WordSet.find_by!(name: word_set_name)
    @word_frequencies = []
  end

  def call
    word_set.words.find_each do |word|
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
      word_frequencies,
      validate_uniqueness: true,
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
