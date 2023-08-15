class AddWordIdFrequencyTableIdIndexToWordFrequencies < ActiveRecord::Migration[7.0]
  def change
    add_index :word_frequencies, [:word_id, :frequency_table_id], unique: true
  end
end
