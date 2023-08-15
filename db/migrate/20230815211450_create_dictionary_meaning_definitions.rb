class CreateDictionaryMeaningDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionary_meaning_definitions do |t|
      t.references :dictionary_meaning, null: false, foreign_key: true, index: { name: 'index_dict_mean_definitions'}
      t.string :text

      t.timestamps
    end
  end
end
