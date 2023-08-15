class WordSet < ApplicationRecord
  has_and_belongs_to_many :words
end
