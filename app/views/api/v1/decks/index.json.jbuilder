# frozen_string_literal: true

json.array! @decks do |deck|
  json.extract! deck, :id, :name, :created_at, :updated_at
  json.words_count deck.words_count
end
