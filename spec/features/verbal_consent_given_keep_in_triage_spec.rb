require "rails_helper"

RSpec.describe "Verbal consent" do
  include EmailExpectations

  scenario "Given, keep in triage" do
    given_i_am_signed_in
    when_i_get_verbal_consent_for_a_patient
    then_the_consent_form_is_prefilled

    when_i_record_that_consent_was_given
    then_i_see_the_consent_responses_page

    when_i_go_to_the_patient
    then_i_see_that_the_status_is_needs_triage
    and_the_kept_in_triage_email_is_sent_to_the_parent
    and_an_email_is_sent_to_the_parent_to_give_feedback
  end

  def given_i_am_signed_in
    team = create(:team, :with_one_nurse)
    campaign = create(:campaign, :hpv, team:)
    @session = create(:session, campaign:, patients_in_session: 1)
    @patient = @session.patients.first

    sign_in team.users.first
  end

  def when_i_get_verbal_consent_for_a_patient
    visit consents_session_path(@session)
    click_link @patient.full_name
    click_button "Get consent"
  end

  def then_the_consent_form_is_prefilled
    expect(page).to have_field("Full name", with: @patient.parent_name)
  end

  def when_i_record_that_consent_was_given
    # Who are you trying to get consent from?
    click_button "Continue"

    # Do they agree?
    choose "Yes, they agree"
    click_button "Continue"

    # Health questions
    find_all(".edit_consent .nhsuk-fieldset")[0].choose "Yes"
    find_all(".edit_consent .nhsuk-fieldset")[0].fill_in "Give details",
              with: "moar allergies"
    find_all(".edit_consent .nhsuk-fieldset")[1].choose "No"
    find_all(".edit_consent .nhsuk-fieldset")[2].choose "No"
    choose "No, keep in triage"
    click_button "Continue"

    # Confirm
    click_button "Confirm"
  end

  def then_i_see_the_consent_responses_page
    expect(page).to have_content("Check consent responses")
    expect(page).to have_content("Record saved for #{@patient.full_name}")
  end

  def when_i_go_to_the_patient
    click_link "View child record"
  end

  def then_i_see_that_the_status_is_needs_triage
    expect(page).to have_content("Needs triage")
  end

  def and_the_kept_in_triage_email_is_sent_to_the_parent
    expect_email_to @patient.parent_email,
                    "604ee667-c996-471e-b986-79ab98d0767c"
  end

  def and_an_email_is_sent_to_the_parent_to_give_feedback
    expect_email_to @patient.parent_email,
                    "1250c83b-2a5a-4456-8922-657946eba1fd",
                    :second
  end
end
