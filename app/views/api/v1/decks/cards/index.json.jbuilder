# frozen_string_literal: true

json.cards @cards do |card|
  json.partial! 'api/v1/decks/cards/card_summary', card:
end

json.pagination @pagination
