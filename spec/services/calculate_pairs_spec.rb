require 'rails_helper'

describe CalculatePairs do

  subject { described_class.new(overrides: overrides, team_model: team) }
  let(:team) { Team.create( name: 'team' ) }
  let!(:team_members) do
    (1..total_team_members).map { |index| team.team_members.create(name: "Person #{index}") }
  end
  let(:total_team_members) { 3 }
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
        person2: TeamMember.solo.id, date: 3.days.ago,
        team_id: team.id)
    end

    #person1 paired with person2 together yesterday
    PairHistory.create(person1: team_members[0].id,
      person2: team_members[1].id, date: 1.day.ago,
      team_id: team.id)

    #person3 solo'd yesterday
    PairHistory.create(person1: team_members[2].id,
      person2: TeamMember.solo.id, date: 1.days.ago,
      team_id: team.id)

    pairs_by_name = subject.pairs.map{ |x| x.map(&:name) }
    expect(pairs_by_name).to include(['Person 1', 'Person 3'], ['Person 2', 'solo'])
  end

  it 'ensures different pairs from yesterday' do
    10.times do
      PairHistory.create(person1: team_members[0].id,
                         person2: team_members[1].id,
                         team_id: team.id, date: 3.days.ago)
      expect(subject.pairs).not_to include([team_members[0], team_members[1]])
      PairHistory.delete_all
    end
  end

  context 'overrides' do

    before do
      #person1 has been solo 5x
      5.times do
        PairHistory.create(person1: team_members[0].id,
                           person2: TeamMember.solo.id, date: 3.days.ago,
                           team_id: team.id)
      end

      #person1 paired with person2 together yesterday
      PairHistory.create(person1: team_members[0].id,
                         person2: team_members[1].id, date: 1.day.ago,
                         team_id: team.id)
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

  it 'ensures only one date history is preserved per day' do
    3.times do
      described_class.new(overrides: overrides, team_model: team).pairs
    end
    expect(PairHistory.count).to eq 2
  end

  context '10 person team' do

    let(:total_team_members) { 10 }

    it 'pairs people evenly over time' do
      90.downto(1).each do |i|
        Timecop.freeze(i.days.ago) do
          described_class.new(overrides: overrides, team_model: team).pairs
        end
      end
      team_member_ids = Team.first.team_members.pluck(:id)
      team_pair_counts = PairHistory.number_of_times_paired(team_member_ids).values
      base_min = team_pair_counts.first.to_f * 0.9
      base_max = team_pair_counts.first.to_f * 1.1
      team_pair_counts.each do |count|
        expect(count >= base_min).to be true
        expect(count <= base_max).to be true
      end
    end
  end
end
