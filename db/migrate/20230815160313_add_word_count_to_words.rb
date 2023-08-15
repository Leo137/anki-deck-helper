class AddWordCountToWords < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :word_count, :integer, default: 0
  end
end
