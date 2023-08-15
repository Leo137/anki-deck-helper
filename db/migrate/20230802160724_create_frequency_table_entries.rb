class CreateFrequencyTableEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :frequency_table_entries do |t|
      t.string :content
      t.string :kana
      t.integer :frequency
      t.references :frequency_table, null: false, foreign_key: true

      t.timestamps
    end
  end
end
