class TriageController < ApplicationController
  include TriageMailerConcern

  before_action :set_session, only: %i[index create update]
  before_action :set_patient, only: %i[create update]
  before_action :set_patient_session, only: %i[create update]
  before_action :set_consent, only: %i[create update]

  after_action :verify_policy_scoped, only: %i[index update]

  layout "two_thirds", except: %i[index]

  def index
    patient_sessions =
      @session
        .patient_sessions
        .strict_loading
        .includes(:campaign, :patient)
        .order("patients.first_name", "patients.last_name")

    tabs_to_states = {
      needs_triage: %w[consent_given_triage_needed triaged_kept_in_triage],
      triage_complete: %w[triaged_ready_to_vaccinate triaged_do_not_vaccinate],
      no_triage_needed: %w[
        consent_refused
        consent_given_triage_not_needed
        vaccinated
        unable_to_vaccinate
      ]
    }

    @tabs =
      patient_sessions.group_by do |patient_session|
        tabs_to_states
          .find { |_, states| patient_session.state.in? states }
          &.first
      end

    # ensure all tabs are present
    tabs_to_states.each_key { |tab| @tabs[tab] ||= [] }
  end

  def create
    @triage = @patient_session.triage.new
    @triage.assign_attributes triage_params.merge(user: current_user)
    if @triage.save(context: :consent)
      @patient_session.do_triage!
      send_triage_mail(@patient_session, @consent)
      success_flash_after_patient_update(
        patient: @patient,
        view_record_link: session_patient_triage_path(@session, @patient)
      )
      redirect_to triage_session_path(@session)
    else
      render "patient_sessions/show", status: :unprocessable_entity
    end
  end

  def update
    @triage = @patient_session.triage.last
    @triage.assign_attributes triage_params
    if @triage.save(context: :consent)
      @patient_session.do_triage!
      send_triage_mail(@patient_session, @consent)
      success_flash_after_patient_update(
        patient: @patient,
        view_record_link: session_patient_triage_path(@session, @patient)
      )
      redirect_to triage_session_path(@session)
    else
      render "patient_sessions/show", status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session =
      policy_scope(Session).find(
        params.fetch(:session_id) { params.fetch(:id) }
      )
  end

  def set_patient
    @patient = @session.patients.find_by(id: params[:patient_id])
  end

  def set_consent
    # HACK: Triage needs to be updated to work with multiple consents.
    @consent = @patient_session.consents.first
  end

  def set_patient_session
    @patient_session = @patient.patient_sessions.find_by(session: @session)
  end

  def triage_params
    params.require(:triage).permit(:status, :notes)
  end
end
