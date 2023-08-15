class AddContentIndexToFrequencyTableEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :frequency_table_entries, :content, unique: false
  end
end
