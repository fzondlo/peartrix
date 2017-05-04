require 'rails_helper'

describe CalculatePairs do
  
  subject { described_class.new(overrides: overrides, team: team) }
  let(:team) { Team.create( name: 'team' ) }
  let!(:people) do 
    (1..3).map { |index| team.people.create(name: "Person #{index}") }
  end
  let(:overrides) { {} }

  it 'creates pairs of two' do  
    pairs = subject.pairs
    pairs.each { |pair| expect(pair.count).to eq(2) }
    expect(pairs.flatten).to include(*(people + [Person.solo]))
  end

  it 'persists database pairing history' do
    subject.pairs
    expect(PairHistory.count).to eq(2)
  end

  it 'ensures different pairs from yesterday' do
    10.times do
      PairHistory.create(person1: people[0].id, person2: people[1].id)
      expect(subject.pairs).not_to include([people[0], people[1]])
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