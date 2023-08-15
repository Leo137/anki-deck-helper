class CreateWordSets < ActiveRecord::Migration[7.0]
  def change
    create_table :word_sets do |t|
      t.string :name

      t.timestamps
    end
  end
end
