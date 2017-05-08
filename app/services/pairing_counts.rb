class PairingCounts
  
  attr_reader :team_member_ids, team_members

  def initialize(team_members)
    @team_member_ids = team_members.select(&:id)
  end

  def for(team_member)
    other_team_members_ids(team_member).each_with_object(Hash.new(0)) do |id, memo|
      key = case id
      when solo_id then :solo
      when out_of_office_id then :out_of_office
      else :id
      end
      memo[key] = number_of_times_paired([team_member.id, id])
    end
  end
  
  private

  def solo_id
    @solo_id ||= TeamMember.solo.id
  end

  def out_of_office_id
    @out_of_office_id ||= TeamMember.out_of_office.id
  end

  def other_team_members_ids(team_member)
    (team_member_ids + [solo_id, out_of_office_id]) - [team_member.id] 
  end

  def number_of_times_paired(pair_ids)
    @number_of_times_paired ||= 
      PairHistory.number_of_times_paired(team_member_ids)
    @number_of_times_paired[pair_ids.sort]
  end
end