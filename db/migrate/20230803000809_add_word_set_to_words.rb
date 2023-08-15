class AddWordSetToWords < ActiveRecord::Migration[7.0]
  def change
    add_reference :words, :word_set, null: false, foreign_key: true
  end
end
