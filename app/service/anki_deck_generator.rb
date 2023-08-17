# frozen_string_literal: true

# Creates anki deck based on a list of words
class AnkiDeckGenerator
  attr_accessor :words, :deck_name

  def initialize(words, deck_name)
    @words = words
    @deck_name = deck_name
  end

  def call
    deck.generate_deck(file: "decks/#{deck_name}.txt")
  end

  private

  def deck
    @deck ||= Anki::Deck.new(
      card_headers: headers,
      card_data: cards,
      field_separator: '|'
    )
  end

  def cards
    @cards ||= generate_cards
  end

  def headers
    [:front, :back]
  end

  def generate_cards
    words.map(&:to_anki_card)
  end
end
