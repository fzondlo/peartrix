class CreateTeamMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :team_members do |t|
      t.integer :team_id, null: false
      t.string :name, null: false
      
      t.timestamps
    end
  end
end
