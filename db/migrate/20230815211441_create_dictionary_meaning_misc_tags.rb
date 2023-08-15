class CreateDictionaryMeaningMiscTags < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionary_meaning_misc_tags do |t|
      t.references :dictionary_meaning, null: false, foreign_key: true, index: { name: 'index_dict_mean_misctags'}
      t.string :code

      t.timestamps
    end
  end
end
