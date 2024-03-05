class ConsentFormMailer < ApplicationMailer
  def confirmation(consent_form: nil, consent: nil, session: nil)
    template_mail(
      "7cda7ae5-99a2-4c40-9a3e-1863e23f7a73",
      **opts(consent_form:, consent:, session:)
    )
  end

  def confirmation_needs_triage(consent_form: nil, consent: nil, session: nil)
    template_mail(
      "604ee667-c996-471e-b986-79ab98d0767c",
      **opts(consent_form:, consent:, session:)
    )
  end

  def confirmation_injection(consent_form: nil, consent: nil, session: nil)
    template_mail(
      "4d09483a-8181-4acb-8ba3-7abd6c8644cd",
      **opts(consent_form:, consent:, session:)
    )
  end

  def confirmation_refused(consent_form: nil, consent: nil, session: nil)
    template_mail(
      "5a676dac-3385-49e4-98c2-fc6b45b5a851",
      **opts(consent_form:, consent:, session:)
    )
  end

  def give_feedback(consent_form: nil, consent: nil, session: nil)
    template_mail(
      "1250c83b-2a5a-4456-8922-657946eba1fd",
      **opts(consent_form:, consent:, session:)
    )
  end

  private

  def opts(consent_form:, consent:, session: nil)
    @consent_form = consent_form
    @consent = consent
    @patient = consent_form || consent.patient
    @session = session || consent_form.session

    { to:, reply_to_id:, personalisation: consent_form_personalisation }
  end

  def consent_form_personalisation
    personalisation.merge(reason_for_refusal:, survey_deadline_date:)
  end

  def reason_for_refusal
    reason = @consent_form&.reason || @consent&.reason_for_refusal
    I18n.t("mailers.consent_form_mailer.reasons_for_refusal.#{reason}")
  end

  def survey_deadline_date
    recorded_at = @consent_form&.recorded_at || @consent.recorded_at

    (recorded_at + 7.days).to_fs(:nhsuk_date)
  end
end
