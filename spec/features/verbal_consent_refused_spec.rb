require "rails_helper"

RSpec.describe "Verbal consent" do
  include EmailExpectations

  scenario "Refused" do
    given_i_am_signed_in
    when_i_get_verbal_consent_for_a_patient
    then_the_consent_form_is_prefilled

    when_i_record_the_consent_refusal_and_reason
    then_i_see_the_consent_responses_page

    when_i_go_to_the_patient
    then_i_see_that_the_status_is_do_not_vaccinate
    and_i_can_see_the_consent_response
    and_an_email_is_sent_to_the_parent_confirming_the_refusal
  end

  def given_i_am_signed_in
    team = create(:team, :with_one_nurse)
    campaign = create(:campaign, :hpv, team:)
    @session = create(:session, campaign:, patients_in_session: 1)
    @patient = @session.patients.first

    sign_in team.users.first
  end

  def when_i_get_verbal_consent_for_a_patient
    visit session_consents_path(@session)
    click_link @patient.full_name
    click_button "Get consent"
  end

  def then_the_consent_form_is_prefilled
    expect(page).to have_field("Full name", with: @patient.parent_name)
  end

  def given_i_call_the_parent_and_they_refuse_consent
  end

  def when_i_record_the_consent_refusal_and_reason
    # Who are you trying to get consent from?
    click_button "Continue"

    # Do they agree?
    choose "No, they do not agree"
    click_button "Continue"

    # Reason
    choose "Medical reasons"
    click_button "Continue"

    # Reason notes
    fill_in "Give details", with: "They have a medical condition"
    click_button "Continue"

    # Confirm
    # BUG: shouldn't be 'Refusal confirmed' as they didn't refuse in the first place
    expect(page).to have_content("Refusal confirmed by #{@patient.parent_name}")
    click_button "Confirm"
  end

  def then_i_see_the_consent_responses_page
    expect(page).to have_content("Check consent responses")
    expect(page).to have_content("Record saved for #{@patient.full_name}")
  end

  def when_i_go_to_the_patient
    click_link "View child record"
  end

  def then_i_see_that_the_status_is_do_not_vaccinate
    expect(page).to have_content("Do not vaccinate")
  end

  def and_i_can_see_the_consent_response
    click_link @patient.parent_name

    expect(page).to have_content(
      ["Response date", Time.zone.today.to_fs(:nhsuk_date_short_month)].join
    )
    expect(page).to have_content(["Decision", "Consent refused"].join)
    expect(page).to have_content(["Response method", "Phone"].join)
    expect(page).to have_content(["Reason for refusal", "Medical reasons"].join)
    expect(page).to have_content(
      ["Refusal details", "They have a medical condition"].join
    )

    expect(page).to have_content(["Full name", @patient.full_name].join)
    expect(page).to have_content(
      ["Date of birth", @patient.date_of_birth.to_fs(:nhsuk_date)].join
    )
    expect(page).to have_content(["School", @patient.location.name].join)

    expect(page).to have_content(["Name", @patient.parent_name].join)
    expect(page).to have_content(
      ["Relationship", @patient.parent_relationship_label].join
    )
    expect(page).to have_content(["Email address", @patient.parent_email].join)
    expect(page).to have_content(["Phone number", @patient.parent_phone].join)

    expect(page).not_to have_content("Answers to health questions")
  end

  def and_an_email_is_sent_to_the_parent_confirming_the_refusal
    expect(sent_emails.count).to eq 1

    expect(sent_emails.last).to be_sent_with_govuk_notify.using_template(
      EMAILS[:triage_vaccination_wont_happen]
    ).to(@patient.parent_email)
  end
end
