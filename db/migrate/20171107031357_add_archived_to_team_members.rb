class AddArchivedToTeamMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :team_members, :archived, :boolean, default: false
  end
end
