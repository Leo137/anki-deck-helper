# frozen_string_literal: true

class AddOriginToWordSets < ActiveRecord::Migration[7.0]
  def change
    add_column :word_sets, :origin, :integer, null: false, default: 0
    add_index :word_sets, %i[name origin], unique: true
  end
end
