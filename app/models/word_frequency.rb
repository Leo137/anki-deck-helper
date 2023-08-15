class WordFrequency < ApplicationRecord
  belongs_to :word
  belongs_to :frequency_table
end
