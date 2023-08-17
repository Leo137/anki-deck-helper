class RemoveUniqueConstraintInTextIndexForDictionaryEntries < ActiveRecord::Migration[7.0]
  def up
    remove_index :dictionary_entries, name: 'index_dictionary_entries_on_text'
    add_index :dictionary_entries, :text  # This adds the index without the unique constraint
  end

  def down
    remove_index :dictionary_entries, :text
    add_index :dictionary_entries, :text, unique: true  # Restore the unique constraint
  end
end
