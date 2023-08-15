class AddMaxFrequencyToFrequencyTables < ActiveRecord::Migration[7.0]
  def change
    add_column :frequency_tables, :max_frequency, :integer
  end
end
