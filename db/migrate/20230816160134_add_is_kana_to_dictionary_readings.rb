class AddIsKanaToDictionaryReadings < ActiveRecord::Migration[7.0]
  def change
    add_column :dictionary_readings, :is_kana, :boolean, default: false
  end
end
