class OverrideOptions

  OPTION = Struct.new(:option_value, :display_text)

  attr_reader :team, :team_member

  def initialize(team, team_member)
    @team = team
    @team_member = team_member
  end

  def options
    standard_options + team_member_options
  end

  private

  def standard_options
    [
      OPTION.new('', '-- Select Override --'),
      OPTION.new(:solo, 'Solo'),
      OPTION.new(:out_of_office, 'Out of Office')
    ]
  end

  def team_member_options
    (team.team_members.to_a - [team_member]).map do |team_mate|
      OPTION.new(team_mate.id, "Pair with #{team_mate.name}")
    end
  end
end
