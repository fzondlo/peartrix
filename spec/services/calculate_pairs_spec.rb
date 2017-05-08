require 'rails_helper'

describe CalculatePairs do
  
  subject { described_class.new(overrides: overrides, team_model: team) }
  let(:team) { Team.create( name: 'team' ) }
  let!(:team_members) do 
    (1..3).map { |index| team.team_members.create(name: "Person #{index}") }
  end
  let(:overrides) { {} }

  it 'creates pairs of two' do
    pairs = subject.pairs
    pairs.each { |pair| expect(pair.count).to eq(2) }
  end

  it 'persists database pairing history' do
    subject.pairs
    expect(PairHistory.count).to eq(2)
  end

  it 'selects best pairs' do
    #person1 has been solo 5x
    5.times do 
      PairHistory.create(person1: team_members[0].id, 
        person2: TeamMember.solo.id, created_at: 3.days.ago)
    end

    #person2 paired wit person1 together yesterday
    PairHistory.create(person1: team_members[0].id,
      person2: team_members[1].id, created_at: 1.day.ago)

    #person3 solo'd yesterday
    PairHistory.create(person1: team_members[2].id,
      person2: TeamMember.solo.id, created_at: 1.days.ago)
    
    pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
    expect(pairs_by_name).to include(['Person1', 'solo'], ['Person3', 'Person2'])
  end

  it 'ensures different pairs from yesterday' do
    10.times do
      PairHistory.create(person1: team_members[0].id, person2: team_members[1].id)
      expect(subject.pairs).not_to include([team_members[0], team_members[1]])
      PairHistory.delete_all
    end
  end

  context 'when odd' do 
    it 'chooses person with least times solo to be solo' do
    end
  end

  context 'overrides' do
    it 'when one is ooo'
    it 'when one is solo'
  end
end