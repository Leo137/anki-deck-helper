class CreateDictionaryMeaningFields < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionary_meaning_fields do |t|
      t.references :dictionary_meaning, null: false, foreign_key: true, index: { name: 'index_dict_mean_fields'}
      t.string :code

      t.timestamps
    end
  end
end
