class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.integer :number
      t.float :x
      t.float :y
      t.string :chromosome
      t.float :score
      t.integer :generation
      t.string :history
      t.boolean :consumed

      t.timestamps
    end
  end
end
