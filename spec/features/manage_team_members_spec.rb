require 'rails_helper'

feature 'Team management', :type => :feature do
  let(:team_name) { 'Some Team' }

  scenario 'User creates a new team' do
    visit '/'
    fill_in 'new_team_name', with: team_name
    click_button 'Submit'
    expect(find('td a').text).to eq(team_name)

    click_link(team_name)
    expect(find('h2').text).to eq(team_name)
  end
end