class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.integer :generation_id
      t.integer :number
      t.float :x
      t.float :y
      t.string :chromosome
      t.float :score
      t.string :history

      t.timestamps
    end
  end
end
