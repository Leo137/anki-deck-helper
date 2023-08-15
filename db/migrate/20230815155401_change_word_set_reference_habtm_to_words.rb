class ChangeWordSetReferenceHabtmToWords < ActiveRecord::Migration[7.0]
  def change
    create_join_table :words, :word_sets
    remove_column :words, :word_set_id
  end
end
