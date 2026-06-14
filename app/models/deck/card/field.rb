# frozen_string_literal: true

class Deck
  class Card
    class Field < ApplicationRecord
      self.table_name = 'deck_card_fields'

      enum :side, { front: 0, back: 1 }

      belongs_to :card, class_name: 'Deck::Card', foreign_key: 'deck_card_id', inverse_of: :fields

      validates :side, presence: true, uniqueness: { scope: :deck_card_id }
      validates :html_content, presence: true
    end
  end
end
