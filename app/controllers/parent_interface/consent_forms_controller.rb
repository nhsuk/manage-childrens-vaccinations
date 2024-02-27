module ParentInterface
  class ConsentFormsController < ConsentForms::BaseController
    include ConsentFormMailerConcern

    layout "two_thirds"

    skip_before_action :set_consent_form, only: %i[start create]
    skip_before_action :authenticate_consent_form_user!, only: %i[start create]

    before_action :clear_session_edit_variables, only: %i[confirm]

    def start
    end

    def create
      vaccine = @session.campaign.vaccines.first
      health_answers = vaccine.health_questions.to_health_answers
      consent_form = @session.consent_forms.create!(health_answers:)

      session[:consent_form_id] = consent_form.id

      redirect_to session_parent_interface_consent_form_edit_path(
                    @session,
                    consent_form,
                    :name
                  )
    end

    def cannot_consent
    end

    def confirm
    end

    def record
      @consent_form.update!(recorded_at: Time.zone.now)

      session.delete(:consent_form_id)

      # send_record_mail(@consent_form)
      #
      # ConsentFormMatchingJob.perform_later(@consent_form.id)
    end

    private

    def clear_session_edit_variables
      session.delete(:follow_up_changes_start_page)
    end
  end
end
