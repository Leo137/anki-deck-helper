# frozen_string_literal: true

# Exports an existing deck's card fields into Anki import format
class DeckAnkiExportGenerator
  class Error < StandardError; end

  attr_reader :deck

  def initialize(deck:)
    @deck = deck
  end

  def call
    validate_exportable!
    FileUtils.mkdir_p(output_directory)
    anki_deck.generate_deck(file: file_path.to_s)
    file_path.to_s
  end

  private

  def validate_exportable!
    raise Error, 'Deck has no cards to export' if deck.cards.none?
  end

  def anki_deck
    @anki_deck ||= Anki::Deck.new(
      card_headers: headers,
      card_data: cards,
      field_separator: '|'
    )
  end

  def cards
    deck.cards.includes(:fields).map do |card|
      {
        front: card.front_field.html_content,
        back: card.back_field.html_content
      }
    end
  end

  def headers
    %i[front back]
  end

  def file_path
    @file_path ||= output_directory.join("#{sanitized_deck_name}.txt")
  end

  def output_directory
    Rails.root.join('tmp/anki_exports')
  end

  def sanitized_deck_name
    deck.name.parameterize.presence || "deck-#{deck.id}"
  end
end
