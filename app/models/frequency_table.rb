class FrequencyTable < ApplicationRecord
  has_many :word_frequencies
  has_many :frequency_table_entries

  def max_frequency
    # update value, return it
    return max_frequency_in_database if max_frequency_in_database
    return 0 unless frequency_table_entries.any?

    update(max_frequency: frequency_table_entries.maximum(:frequency))
    max_frequency_in_database
  end
end
