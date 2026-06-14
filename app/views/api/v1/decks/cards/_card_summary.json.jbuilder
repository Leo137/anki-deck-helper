# frozen_string_literal: true

json.extract! card, :id, :position, :created_at, :updated_at
json.front_preview card.front_preview
