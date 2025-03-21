class CreateOpportunities < ActiveRecord::Migration[8.0]
  def change
    create_table :opportunities do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :salary, precision: 10, scale: 2, null: false
      t.references :client, null: false, foreign_key: true, index: true

      t.timestamps
    end
    
    add_index :opportunities, :title
  end
end
