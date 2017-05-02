class Team < ApplicationRecord
  has_many :people, foreign_key: :team_id, class_name: :Person
end
