# frozen_string_literal: true

class RefactorDeckWordsToDeckCards < ActiveRecord::Migration[7.0]
  def change
    drop_table :deck_words do |t|
      t.references :deck, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.integer :position, null: false
      t.timestamps
    end

    create_table :deck_cards do |t|
      t.references :deck, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :deck_cards, %i[deck_id position], unique: true

    create_table :deck_card_fields do |t|
      t.references :deck_card, null: false, foreign_key: true
      t.integer :side, null: false
      t.text :html_content, null: false, default: ''

      t.timestamps
    end

    add_index :deck_card_fields, %i[deck_card_id side], unique: true
  end
end
