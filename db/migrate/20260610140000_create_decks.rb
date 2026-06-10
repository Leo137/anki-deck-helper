# frozen_string_literal: true

class CreateDecks < ActiveRecord::Migration[7.0]
  def change
    create_table :decks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :decks, %i[user_id name], unique: true

    create_table :deck_words do |t|
      t.references :deck, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :deck_words, %i[deck_id word_id], unique: true
    add_index :deck_words, %i[deck_id position], unique: true
  end
end
