# frozen_string_literal: true

json.extract! @card, :id, :position, :created_at, :updated_at
json.deck do
  json.extract! @deck, :id, :name
end
json.fields(@card.fields.sort_by { |field| Deck::Card::Field.sides[field.side] }) do |field|
  json.extract! field, :id, :side, :html_content, :created_at, :updated_at
end
