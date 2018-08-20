require 'mailgun'

class TeamsController < ApplicationController
  helper_method :overrides_for

  def index
    @homepage = true
    @teams = Team.all
    @new_team = Team.new
  end

  def create
    Team.create!(name: team_name)
    redirect_to action: :index
  end

  def pairs
    send_email(calculate_pairs_service.pairs)
    redirect_to action: :show, id: team_id
  end

  def show
    @new_person = TeamMember.new(team_id: team_id)
  end

  private

  helper_method :team
  def team
    @team ||= Team.find(team_id)
  end

  helper_method :team_members
  def team_members
    @team_members ||= team.members_including_statuses
  end
  
  helper_method :todays_pairs
  def todays_pairs
    @todays_pairs ||= TodaysPairs.new(team: team).pairs
  end

  helper_method :number_of_times_paired_by_name
  def number_of_times_paired_by_name
    @number_of_times_paired_by_name ||=
      PairHistory.number_of_times_paired_by_name(team.team_members.pluck(:id))
  end

  helper_method :pair_matrix_per_person
  def pair_matrix_per_person
    @pair_matrix_per_person ||= PairHistory.pair_matrix_per_person(team)
  end

  def send_email(pairs)
    return if Rails.env.development?
    mg_client = Mailgun::Client.new 'key-c7fa511f484c6c8c038a6de70c212a0a'
    message_params = {:from    => 'peartrix@herokuapp.com',
                      :to      => 'fzondlo@gmail.com',
                      :subject => "Pairs for #{team.name} - #{Date.today}",
                      :text    => email_text(pairs)}
    mg_client.send_message 'app03158b70ec6646fe8ae0d6115e0219e3.mailgun.org', message_params
  rescue Mailgun::CommunicationError => e
    Rails.logger.info("ERROR! #{e.exception}: #{e.message}")
  end

  def email_text(pairs)
    pairs.map { |p| "#{p.first.name} - #{p.last.name}" }.join("\n")
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

  def team_id
    params[:team_id] || params[:id]
  end

  def team_name
    params.require(:new_team).require(:name)
  end
end


