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

    #person1 paired with person2 together yesterday
    PairHistory.create(person1: team_members[0].id,
      person2: team_members[1].id, created_at: 1.day.ago)

    #person3 solo'd yesterday
    PairHistory.create(person1: team_members[2].id,
      person2: TeamMember.solo.id, created_at: 1.days.ago)

    pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
    expect(pairs_by_name).to include(['Person 1', 'Person 3'], ['Person 2', 'solo'])
  end

  it 'ensures different pairs from yesterday' do
    10.times do
      PairHistory.create(person1: team_members[0].id, person2: team_members[1].id)
      expect(subject.pairs).not_to include([team_members[0], team_members[1]])
      PairHistory.delete_all
    end
  end

  context 'overrides' do

    before do
      #person1 has been solo 5x
      5.times do
        PairHistory.create(person1: team_members[0].id,
                           person2: TeamMember.solo.id, created_at: 3.days.ago)
      end

      #person1 paired with person2 together yesterday
      PairHistory.create(person1: team_members[0].id,
                         person2: team_members[1].id, created_at: 1.day.ago)
    end

    context 'person 1 is overrriden to solo' do
      let(:overrides) { { team_members.first.id => :solo } }
      it 'pairs correctly' do
        pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
        expect(pairs_by_name).to include(['Person 1', 'solo'], ['Person 2', 'Person 3'])
      end
    end

    context 'person 1 is overridden to out of office' do
      let(:overrides) { { team_members.first.id => :out_of_office } }
      it 'pairs correctly' do
        pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
        expect(pairs_by_name).to include(['Person 1', 'out_of_office'], ['Person 2', 'Person 3'])
      end
    end

    context 'is manually paired with person 2' do
      let(:overrides) { { team_members.first.id => team_members.second.id } }
      it 'pairs correctly' do
        pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
        expect(pairs_by_name).to include(['Person 1', 'Person 2'], ['Person 3', 'solo'])
      end
    end
  end
end
