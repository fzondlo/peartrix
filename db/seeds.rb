GRYFFINDOR_MEMBERS = %w[Harry Ron Hermione Dean Neville Ginny Colin].freeze
SLYTHERIN_MEMBERS = %w[Draco Crabbe Goyle Millicent].freeze
RAVENCLAW_MEMBERS = %w[Cho Padma Luna Myrtle].freeze
HUFFLEPUFF_MEMBERS = %w[Cedric Justin Hannah Tonks Lupin].freeze

TEAMS = {
  'Gryffindor' => GRYFFINDOR_MEMBERS,
  'Slytherin' => SLYTHERIN_MEMBERS,
  'Ravenclaw' => RAVENCLAW_MEMBERS,
  'Hufflepuff' => HUFFLEPUFF_MEMBERS
}.freeze

TEAMS.each do |name, members|
  team = Team.create(name: name)

  members.each do |member|
    team.team_members.create(name: member)
  end
end

gryffindor = GRYFFINDOR_MEMBERS.dup
gryffindor_id = Team.find_by(name: 'Gryffindor').id

gryffindor.reverse_each do |name|
  member = TeamMember.find_by(name: name)
  others = gryffindor.reject { |n| n == name }

  others.each do |pair_name|
    pair = TeamMember.find_by(name: pair_name)
    random = rand(5)

    random.times do
      some = rand(7)
      pair_ids = [member.id, pair.id].sort
      PairHistory.create(person1: pair_ids[0],
                         person2: pair_ids[1],
                         date: some.days.ago,
                         team_id: gryffindor_id)
    end
  end
  gryffindor.pop
end
