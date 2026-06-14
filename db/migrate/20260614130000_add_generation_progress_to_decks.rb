# frozen_string_literal: true

class AddGenerationProgressToDecks < ActiveRecord::Migration[7.0]
  def change
    add_column :decks, :generation_progress, :integer, null: false, default: 0
    add_column :decks, :generation_total, :integer
  end
end
