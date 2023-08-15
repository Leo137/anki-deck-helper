class AddContentFrequencyTableIdIndexToFrequencyTableEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :frequency_table_entries, [:content, :frequency_table_id], unique: true
  end
end
