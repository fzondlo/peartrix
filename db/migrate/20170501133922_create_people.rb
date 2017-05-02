class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.integer :team_id, null: false
      t.string :name, null: false
      
      t.timestamps
    end
  end
end
