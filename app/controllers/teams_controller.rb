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
  end

  def show
    team
    @new_person = Person.new(team_id: team_id)
  end

  private

  def overrides_for(person)
    OverrideOptions.new(team, person).options
  end

  def team
    @team ||= Team.find(team_id)
  end

  def team_id
    params.require(:id)
  end

  def team_name
    params.require(:new_team).require(:name)
  end
end
