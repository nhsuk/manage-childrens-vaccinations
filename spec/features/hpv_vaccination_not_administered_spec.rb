require "rails_helper"

describe "HPV Vaccination" do
  include EmailExpectations

  scenario "Not administered" do
    given_i_am_signed_in
    when_i_go_to_a_patient_that_is_ready_to_vaccinate
    and_i_record_that_the_patient_wasnt_vaccinated
    and_i_select_the_reason_why
    then_i_see_the_confirmation_page

    when_i_confirm_the_details
    then_i_see_the_record_vaccinations_page
    and_a_success_message

    when_i_go_to_the_patient
    then_i_see_that_the_status_is_could_not_vaccinate
    and_an_email_is_sent_saying_the_vaccination_didnt_happen
  end

  def given_i_am_signed_in
    team = create(:team, :with_one_nurse, :with_one_location)
    campaign = create(:campaign, :hpv, team:)
    @batch = campaign.batches.first
    @session = create(:session, campaign:, location: team.locations.first)
    @patient =
      create(
        :patient_with_consent_given_triage_not_needed,
        session: @session,
        location: @session.location
      )

    sign_in team.users.first
  end

  def when_i_go_to_a_patient_that_is_ready_to_vaccinate
    visit vaccinations_session_path(@session)
    click_link @patient.full_name
  end

  def and_i_record_that_the_patient_wasnt_vaccinated
    choose "No, they did not get it"
    click_button "Continue"
  end

  def and_i_select_the_reason_why
    choose "They refused it"
    click_button "Continue"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Check and confirm")
    expect(page).to have_content("Child#{@patient.full_name}")
    expect(page).to have_content("OutcomeRefused vaccine")
  end

  def when_i_confirm_the_details
    click_button "Confirm"
  end

  def then_i_see_the_record_vaccinations_page
    expect(page).to have_content("Record vaccinations")
  end

  def and_a_success_message
    expect(page).to have_content("Record saved for #{@patient.full_name}")
  end

  def when_i_go_to_the_patient
    click_link "View child record"
  end

  def then_i_see_that_the_status_is_could_not_vaccinate
    expect(page).to have_content("Could not vaccinate")
    expect(page).to have_content("ReasonRefused vaccine")
  end

  def and_an_email_is_sent_saying_the_vaccination_didnt_happen
    expect_email_to(
      @patient.consents.last.parent_email,
      EMAILS[:confirming_the_hpv_vaccination_didnt_happen]
    )
  end
end
