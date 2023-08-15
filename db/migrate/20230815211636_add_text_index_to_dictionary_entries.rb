class AddTextIndexToDictionaryEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :dictionary_entries, :text, unique: true
  end
end
