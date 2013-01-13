class CreateGenerations < ActiveRecord::Migration
  def change
    create_table :generations do |t|
      t.integer :number
      t.float :score
      t.boolean :consumed, default: false, null: false

      t.timestamps
    end
  end
end
