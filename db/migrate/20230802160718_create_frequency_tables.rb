class CreateFrequencyTables < ActiveRecord::Migration[7.0]
  def change
    create_table :frequency_tables do |t|
      t.string :name

      t.timestamps
    end
  end
end
