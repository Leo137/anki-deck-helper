# frozen_string_literal: true

json.partial! 'api/v1/decks/deck', deck: @deck, cards_count: @cards_count
json.study_summary do
  json.partial! 'api/v1/decks/study_summary', study_summary: @study_summary
end
