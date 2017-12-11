class Team < ApplicationRecord
  has_many :team_members, -> { where(archived: false) }

  def members_including_statuses
    team_members + [TeamMember.solo, TeamMember.out_of_office]
  end
end
