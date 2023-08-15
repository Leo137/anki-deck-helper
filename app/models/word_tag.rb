class WordTag < ApplicationRecord
  belongs_to :word
  belongs_to :tag
end
