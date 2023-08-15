class CreateWords < ActiveRecord::Migration[7.0]
  def change
    create_table :words do |t|
      t.string :content
      t.string :kana
      t.datetime :exported_at
      t.datetime :added_at

      t.timestamps
    end
  end
end
