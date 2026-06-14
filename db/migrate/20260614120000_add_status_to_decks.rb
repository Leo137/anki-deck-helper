# frozen_string_literal: true

class AddStatusToDecks < ActiveRecord::Migration[7.0]
  def change
    add_column :decks, :status, :integer, null: false, default: 0
    add_column :decks, :error_message, :text
  end
end
