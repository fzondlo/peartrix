class TodaysPairs

  attr_reader :team

  def initialize(team:)
    @team = team
  end

  def pairs
    return [] if history.empty?
    pair_ids.map do |ids|
      [
        team_members_by_id[ids.first],
        team_members_by_id[ids.last]
      ]
    end
  end

  private

  def history
    PairHistory.where(team_id: team.id, date: Date.today)
  end

  def pair_ids
    @pair_ids ||= history.pluck(:person1, :person2)
  end

  def team_members_by_id
    @team_members_by_id ||= begin
      members = TeamMember.where('id in (?)', pair_ids.flatten).to_a
      Hash[members.map(&:id).zip(members)]
    end
  end
end