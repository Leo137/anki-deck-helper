class AddFrequencyIndexToFrequencyTableEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :frequency_table_entries, :frequency, unique: false
  end
end
