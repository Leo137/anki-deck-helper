# frozen_string_literal: true

class DeckWord < ApplicationRecord
  belongs_to :deck
  belongs_to :word

  validates :position, presence: true, uniqueness: { scope: :deck_id }
  validates :word_id, uniqueness: { scope: :deck_id }
end
