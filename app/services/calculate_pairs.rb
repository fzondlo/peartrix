class CalculatePairs

  attr_reader :overrides, :team_model

  delegate :team_members, :available_member_ids, :members_left_to_pair,
           :to => :team

  def initialize(overrides: {}, team_model:)
    @overrides = overrides
    @team_model = team_model
  end

 def pairs
    @pairs ||= begin
      set_pairs_from_overrides
      set_odd_person if team_odd?
      set_best_pairs
      persist_pairs
    end
  end

  private

  def set_pairs_from_overrides
    overrides.each_pair do |member1_id, member2_id|
      next if member2_id == ''
      member1 = find_member_by_id(member1_id.to_i)
      member2 = case member2_id.try(:to_sym)
        when :out_of_office then TeamMember.out_of_office
        when :solo then TeamMember.solo
        else find_member_by_id(member2_id.to_i)
      end
      team.set_pair(member1, member2)
    end
  end

  def find_member_by_id(id)
    team_members.find { |member| member.id == id }
  end

  def list_of_pairs
    @list_of_pairs ||= team_members.each_with_object(Set.new) do |team_member, memo|
      memo << [team_member, team_member.paired_with].sort_by(&:id)
    end
  end

  def set_best_pairs
    while members_left_to_pair.any?
      member1 = team.next_member_to_pair
      member2_id = member1.find_best_pair_from(available_member_ids)
      member2 = members_left_to_pair.find{|member| member.id == member2_id}
      team.set_pair(member1, member2)
    end
  end

  def available_member_ids
    members_left_to_pair.map(&:id)
  end

  def team_odd?
    members_left_to_pair.count.odd?
  end

  def team
    @team ||= TeamDecorator.new(team_model)
  end

  def set_odd_person
    member = if members_left_to_pair.one?
      members_left_to_pair.first
    else
      members_left_to_pair.reject(&:last_solo?)
        .min_by{ |member| member.pair_counts[:solo] }
    end
    member.paired_with = TeamMember.solo
  end

  def persist_pairs
    PairHistory.where(team_id: team.id, date: Date.today).delete_all
    list_of_pairs.each do |pair|
      PairHistory.create!(team_id: team.id, person1: pair.first.id, person2: pair.last.id, date: Date.today)
    end
  end
end
