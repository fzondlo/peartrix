GRYFFINDOR_MEMBERS = %w(Harry Ron Hermione Dean Neville Ginny Colin).freeze
SLYTHERIN_MEMBERS = %w(Draco Crabbe Goyle Millicent).freeze
RAVENCLAW_MEMBERS = %w(Cho Padma Luna Myrtle).freeze
HUFFLEPUFF_MEMBERS = %w(Cedric Justin Hannah Tonks Lupin).freeze

TEAMS = {
  'Gryffindor': GRYFFINDOR_MEMBERS,
  'Slytherin': SLYTHERIN_MEMBERS,
  'Ravenclaw': RAVENCLAW_MEMBERS,
  'Hufflepuff': HUFFLEPUFF_MEMBERS
}

TEAMS.each do |name, members|
  team = Team.create(name: name)

  members.each do |member|
    team.team_members.create(name: member)
  end
end
