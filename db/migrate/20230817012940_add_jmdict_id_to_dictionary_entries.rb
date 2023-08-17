class AddJmdictIdToDictionaryEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :dictionary_entries, :jmdict_id, :integer
  end
end
