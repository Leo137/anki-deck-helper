# frozen_string_literal: true

class AddDictionaryIdToDictionaryMeanings < ActiveRecord::Migration[7.0]
  def change
    add_reference :dictionary_meanings, :dictionary, null: true, foreign_key: true
  end
end
