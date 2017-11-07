require 'rails_helper'

feature 'Team management', :type => :feature do
  let!(:team)        { Team.create(name: 'x', id: 1) }
  let!(:team_member) { team.team_members.create(name: 'Chris') }

  before do
    visit 'teams/1/'
  end

  scenario 'adds team member' do
    expect(page).not_to have_content('John')
    fill_in 'team_member_name', with: 'John'
    click_button 'Submit'
    expect(page).to have_content('John')
  end

  scenario 'archives / deletes team member' do
    expect(page).to have_content('Chris')
    find(:css, 'a[data-confirm]').click
    expect(page).not_to have_content('Chris')
  end

  scenario 'calculates pairs' do
    #TODO!
  end
end