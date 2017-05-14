class MembersController < ApplicationController

  def create
    team.team_members.create(name: params.require('team_member').require('name'))
    redirect_to :back
  end

  def show
  end

  private

  def team
    @team ||= Team.find(team_id)
  end

  def team_id
    params.require(:team_id)
  end
end
