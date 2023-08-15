class CreateWordFrequencies < ActiveRecord::Migration[7.0]
  def change
    create_table :word_frequencies do |t|
      t.integer :frequency
      t.references :word, null: false, foreign_key: true
      t.references :frequency_table, null: false, foreign_key: true

      t.timestamps
    end
  end
end
