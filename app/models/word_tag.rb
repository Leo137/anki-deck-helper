# frozen_string_literal: true

class WordTag < ApplicationRecord
  belongs_to :word
  belongs_to :tag
end
