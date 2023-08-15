class AddContentIndexToWords < ActiveRecord::Migration[7.0]
  def change
    add_index :words, :content, unique: false
  end
end
