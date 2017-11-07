class Team < ApplicationRecord
  has_many :team_members, -> { where(archived: false) }
end
