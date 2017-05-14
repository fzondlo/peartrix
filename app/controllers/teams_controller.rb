class TeamsController < ApplicationController
  helper_method :overrides_for

  def index
    @teams = Team.all
    @new_team = Team.new
  end

  def create
    Team.create!(name: team_name)
    redirect_to action: :index
  end

  def pairs
    @pairs = calculate_pairs_service.pairs
  end

  def show
    team
    @new_person = TeamMember.new(team_id: team_id)
  end

  private

  def overrides
    params.require('overrides')
  end

  def calculate_pairs_service
    CalculatePairs.new(overrides: overrides, team_model: team)
  end

  def overrides_for(person)
    OverrideOptions.new(team, person).options
  end

  def team
    @team ||= Team.find(team_id)
  end

  def team_id
    params[:team_id] || params[:id]
  end

  def team_name
    params.require(:new_team).require(:name)
  end
end
