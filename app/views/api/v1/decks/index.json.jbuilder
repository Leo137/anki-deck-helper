# frozen_string_literal: true

json.array! @decks do |deck|
  json.partial! 'api/v1/decks/deck', deck:, cards_count: deck.cards_count
end
