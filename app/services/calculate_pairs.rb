class CalculatePairs
  
  attr_reader :overrides
  
  delegate :team_members, :available_member_ids, 
           :to => team_with_history
  
  def initialize(overrides:, team_model:)
    @overrides = overrides
    @team_model = team_model
  end

  def pairs
    @pairs ||= begin
      set_pairs_from_overrides
      set_odd_person if team_odd?
      set_best_pairs
      persist_pairs
      list_of_pairs
    end
  end

  private

  def set_pairs_from_overrides
    #TODO : IMPLEMENT
  end

  def list_of_pairs
    @list_of_pairs ||= team_members.each_with_object(Set.new) do |team_member, memo|
      memo << [team_member, team_member.paired_with].sort_by(&:__id__)
    end
  end

  def set_best_pairs
    while members_left_to_pair.any?
      member1 = team.next_member_to_pair
      member2 = member1.find_best_pair_from(available_member_ids)
      team.set_pair(member1, member2)
    end
  end

  def available_member_ids
    members_left_to_pair.map(&:id)
  end

  def team_odd?
    members_left_to_pair.odd?  
  end

  def team
    @team ||= TeamWithHistory.new(team_model)
  end

  def set_odd_person
    team_members.reject( |member| member.last_solo? )
      .min{ |member| member.pair_counts[:solo] }
      .paired_with(TeamMember.solo)
  end

  def persist_pairs
    list_of_pairs.each do |pair|
      PairHistory.create!(person1: pair.first.id, person2: pair.last.id)
    end
  end
end