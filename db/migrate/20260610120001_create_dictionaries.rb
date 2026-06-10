# frozen_string_literal: true

class CreateDictionaries < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionaries do |t|
      t.string :name, null: false
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end

    add_index :dictionaries, %i[name language_id], unique: true
  end
end
