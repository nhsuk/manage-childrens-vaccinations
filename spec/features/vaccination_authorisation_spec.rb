require "rails_helper"

RSpec.describe "Vaccination authorisation" do
  scenario "Unable to access other teams' vaccinations" do
    given_an_hpv_campaign_is_underway_with_two_teams
    when_i_sign_in_as_a_nurse_from_one_team
    and_i_go_to_the_vaccinations_page
    then_i_should_only_see_my_patients

    when_i_go_to_the_vaccinations_page_of_another_team
    then_i_should_see_page_not_found

    when_i_go_to_the_vaccination_record_page_belonging_to_another_team
    then_i_should_see_page_not_found
  end

  def given_an_hpv_campaign_is_underway_with_two_teams
    @team = create(:team, :with_one_nurse)
    @other_team = create(:team, :with_one_nurse)
    campaign = create(:campaign, :hpv, team: @team)
    other_campaign = create(:campaign, :hpv, team: @other_team)
    location = create(:location, name: "Pilot School", team: @team)
    other_location = create(:location, name: "Other School", team: @other_team)
    @session =
      create(:session, :in_future, campaign:, location:, patients_in_session: 1)
    @other_session =
      create(
        :session,
        :in_future,
        campaign: other_campaign,
        location: other_location,
        patients_in_session: 1
      )
    @child = @session.patients.first
    @other_child = @other_session.patients.first
  end

  def when_i_sign_in_as_a_nurse_from_one_team
    sign_in @team.users.first
  end

  def and_i_go_to_the_vaccinations_page
    visit "/dashboard"
    click_on "School sessions", match: :first
    click_on "Pilot School"
    click_on "Record vaccinations"
  end

  def then_i_should_only_see_my_patients
    expect(page).to have_content(@child.full_name)
    expect(page).not_to have_content(@other_child.full_name)
  end

  def when_i_go_to_the_vaccinations_page_of_another_team
    visit "/sessions/#{@other_session.id}/vaccinations"
  end

  def then_i_should_see_page_not_found
    expect(page).to have_content("Page not found")
  end

  def when_i_go_to_the_vaccination_record_page_belonging_to_another_team
    visit "/sessions/#{@other_session.id}/patients/#{@other_child.id}/vaccinations"
  end
end