class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :word_tags
  has_many :words, through: :word_tags
end
