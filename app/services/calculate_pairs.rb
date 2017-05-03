class CalculatePairs
  
  attr_reader :overrides, :team, :people_to_be_paired
  
  def initialize(overrides, team)
    @overrides = overrides
    @team = team
  end

  def pairs
    @people_to_be_paired = []
    (1..5).each_slice(2).to_a
  end

  private
end