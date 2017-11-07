class MembersController < ApplicationController

  def create
    team.team_members.create(name: params.require('team_member').require('name'))
    redirect_to :back
  end

  def show
  end

  def destroy
    team_member.update_attributes!(archived: true)
    redirect_to :back
  end

  private

  def team_member
    @team_member ||= TeamMember.find(team_member_id)
  end

  def team_member_id
    params.require(:id)
  end

  def team
    @team ||= Team.find(team_id)
  end

  def team_id
    params.require(:team_id)
  end
end
