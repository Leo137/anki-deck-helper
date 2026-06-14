# frozen_string_literal: true

json.extract! deck, :id, :name, :status, :error_message, :generation_progress, :generation_total,
              :created_at, :updated_at
json.cards_count cards_count
