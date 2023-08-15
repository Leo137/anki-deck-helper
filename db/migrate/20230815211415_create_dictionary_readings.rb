class CreateDictionaryReadings < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionary_readings do |t|
      t.references :dictionary_entry, null: false, foreign_key: true
      t.string :text

      t.timestamps
    end
  end
end
