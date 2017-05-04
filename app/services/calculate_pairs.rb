class CalculatePairs
  
  attr_reader :overrides, :team, :people_to_be_paired
  
  def initialize(overrides:, team:)
    @overrides = overrides
    @team = team
  end

  def pairs
    @pairs = []
    create_pairs
    persist_pairs
  end

  private

  def possible_pairs_by_id
    @possible_pairs_by_id ||= people_to_be_paired.each_with_object({}) do |person, memo|
      memo[person.id] = team_member_ids - [person.id, last_paired_with_by_id(person.id)]
    end
  end

  def people_to_be_paired
    @people_to_be_paired ||= team_members.to_a
  end

  def create_pairs
    sort_possible_pairs_by_possible_combinations
    while possible_pairs_for_person_by_id = possible_pairs_by_id.shift
      current_pair_ids = find_and_shift_pair(possible_pairs_for_person_by_id)
      @pairs << current_pair_ids.map{ |id| team_members_by_id(id) }
      remove_used_ids_from_remaining_possible_pears
      sort_possible_pairs_by_possible_combinations
    end
  end

  def find_and_shift_pair(possible_pairs_for_person_by_id)
    current_pair_ids = [possible_pairs_for_person_by_id.first]
    possible_pair_id_matches = possible_pairs_for_person_by_id.last
    current_pair_ids << find_pair_for(current_pair_ids[0], possible_pair_id_matches)
    possible_pairs_by_id.delete(current_pair_ids[1])
    current_pair_ids
  end

  def remove_used_ids_from_remaining_possible_pears
    used_ids = @pairs.flatten.map(&:id)
    possible_pairs_by_id.each do |id, possible_pear_ids|
      possible_pairs_by_id[id] -= used_ids
    end
  end

  def team_members_by_id(id)
    @team_members_by_id ||= Hash[team_member_ids.zip(team_members)]
    @team_members_by_id[id]
  end

  def sort_possible_pairs_by_possible_combinations
    Hash[possible_pairs_by_id.sort_by{ |_,v| v.count }]
  end

  def find_pair_for(person_id, possible_pair_ids)
    possible_pair_ids.min do |pair_id|
      number_of_times_paired([pair_id, person_id].sort)
    end
  end
  
  def number_of_times_paired(pair_ids)
    @number_of_times_paired ||= 
      PairHistory.number_of_times_paired(team_member_ids)
    @number_of_times_paired[pair_ids] || 0
  end

  def last_paired_with_by_id(person_id)
    @last_paired_with_by_id ||= 
      PairHistory.last_time_pairing_by_id(team_members.pluck(:id))
    @last_paired_with_by_id[person_id]
  end

  def team_member_ids
    team_members.map(&:id)
  end

  def team_members
    @team_members ||= begin
      members = team.people.to_a
      members << Person.solo if members.count.odd?
    end
  end

  def persist_pairs
    @pairs.each do |pair|
      PairHistory.create!(person1: pair.first.id, person2: pair.last.id)
    end
  end
end