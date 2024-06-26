# frozen_string_literal: true

require "rails_helper"

describe "Verbal consent" do
  include EmailExpectations

  scenario "Given, keep in triage" do
    given_i_am_signed_in

    when_i_record_that_consent_was_given_but_keep_in_triage

    then_an_email_is_sent_to_the_parent_about_triage
    and_the_patient_status_is_needing_triage
  end

  def given_i_am_signed_in
    team = create(:team, :with_one_nurse)
    campaign = create(:campaign, :hpv, team:)
    @session = create(:session, campaign:, patients_in_session: 1)
    @patient = @session.patients.first

    sign_in team.users.first
  end

  def when_i_record_that_consent_was_given_but_keep_in_triage
    visit session_consents_path(@session)
    click_link @patient.full_name
    click_button "Get consent"

    # Who are you trying to get consent from?
    click_button "Continue"

    # How was the response given?
    choose "By phone"
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
    click_button "Continue"

    choose "No, keep in triage"
    click_button "Continue"

    # Confirm
    click_button "Confirm"

    expect(page).to have_content("Check consent responses")
    expect(page).to have_content("Consent recorded for #{@patient.full_name}")
  end

  def and_the_patient_status_is_needing_triage
    click_link @patient.full_name
    expect(page).to have_content("Needs triage")
  end

  def then_an_email_is_sent_to_the_parent_about_triage
    expect(sent_emails.count).to eq 1

    expect(sent_emails.last).to be_sent_with_govuk_notify.using_template(
      EMAILS[:parental_consent_confirmation_needs_triage]
    ).to(@patient.parent.email)
  end
end
