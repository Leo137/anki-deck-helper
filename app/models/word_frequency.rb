class WordFrequency < ApplicationRecord
  belongs_to :word
  belongs_to :frequency_table

  def ratio_frequency
    frequency / frequency_table&.max_frequency.to_f
  end
end
