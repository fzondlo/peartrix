require 'mailgun'

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
    send_email
  end

  def show
    @todays_pairs = todays_pairs
    @new_person = TeamMember.new(team_id: team_id)
  end

  def show_history
    @number_of_times_paired_by_name = number_of_times_paired_by_name
  end

  private

  def todays_pairs
    TodaysPairs.new(team: team).pairs
  end

  def number_of_times_paired_by_name
    PairHistory.number_of_times_paired_by_name(team.team_members.pluck(:id))
  end

  def send_email
    return if Rails.env.development?
    mg_client = Mailgun::Client.new 'key-c7fa511f484c6c8c038a6de70c212a0a'
    message_params = {:from    => 'peartrix@herokuapp.com',
                      :to      => 'fzondlo@gmail.com',
                      :subject => "Pairs for #{team.name} - #{Date.today}",
                      :text    => email_text}
    mg_client.send_message 'app03158b70ec6646fe8ae0d6115e0219e3.mailgun.org', message_params
  end

  def email_text
    @pairs.map { |p| "#{p.first.name} - #{p.last.name}" }.join("\n")
  end

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


