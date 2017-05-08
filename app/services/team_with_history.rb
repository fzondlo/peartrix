class TeamWithHistory

  attr_reader :team

  def initialize(team)
    @team = team
  end
  
  def team_members
    @team_members ||= team.team_members.to_a.map do |member|
      TeamMemberDecorator.new(
        member: member,
        overrides: {},
        last_paired_with_id: last_paired_with_by_id(member.id)
        pair_counts: pairing_counts.for(member)
      )
    end

  def members_left_to_pair
    team_members.reject(&:paired?)
  end

  def next_member_to_pair
    team_members.min do |member|
      (available_member_ids - [member.id, member.last_paired_with_by_id]).count
    end
  end  

  def available_member_ids
    members_left_to_pair.map(&:id)
  end
  
  def set_pair(member1, member2)
    member1.paired_with = member2
    member2.paired_with = member1
  end

  private

  def last_paired_with_by_id(person_id)
    @last_paired_with_by_id ||= 
      PairHistory.last_time_pairing_by_id(team.team_members.pluck(:id))
    @last_paired_with_by_id[person_id]
  end

  def pairing_counts
    @pairing_counts ||= PairingCounts.new(team.team_members)
  end
end