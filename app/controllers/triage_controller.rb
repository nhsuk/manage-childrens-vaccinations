class TriageController < ApplicationController
  before_action :set_session, only: %i[index show create update]
  before_action :set_patient, only: %i[show create update]
  before_action :set_patient_session, only: %i[create update show]
  before_action :set_triage, only: %i[show]
  before_action :set_consent_response, only: %i[show]
  before_action :set_vaccination_record, only: %i[show]

  layout "two_thirds", except: %i[index]

  def index
    @patient_sessions =
      @session
        .patient_sessions
        .includes(:vaccination_records, patient: %i[consent_responses triage])
        .order("patients.first_name", "patients.last_name")
  end

  def show
  end

  def create
    @triage = Triage.new(campaign: @session.campaign, patient: @patient)
    if @triage.update(triage_params)
      @patient_session.do_triage!
      redirect_to triage_session_path(@session),
                  flash: {
                    success: {
                      title: "Record saved for #{@patient.full_name}",
                      body:
                        ActionController::Base.helpers.link_to(
                          "View child record",
                          session_patient_triage_path(@session, @patient)
                        )
                    }
                  }
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update
    @triage = @patient.triage_for_campaign(@session.campaign)
    if @triage.update(triage_params)
      @patient_session.do_triage!
      redirect_to triage_session_path(@session),
                  flash: {
                    success: {
                      title: "Record saved for #{@patient.full_name}",
                      body:
                        ActionController::Base.helpers.link_to(
                          "View child record",
                          session_patient_triage_path(@session, @patient)
                        )
                    }
                  }
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session = Session.find(params.fetch(:session_id) { params.fetch(:id) })
  end

  def set_patient
    @patient = @session.patients.find_by(id: params[:patient_id])
  end

  def set_triage
    @triage =
      @patient.triage_for_campaign(@session.campaign) ||
        Triage.new(campaign: @session.campaign, patient: @patient)
  end

  def set_consent_response
    @consent_response =
      @patient.consent_response_for_campaign(@session.campaign)
  end

  def set_vaccination_record
    @vaccination_record =
      @patient
        .vaccination_records_for_session(@session)
        .where.not(recorded_at: nil)
        .first
  end

  def set_patient_session
    @patient_session = @patient.patient_sessions.find_by(session: @session)
  end

  def triage_params
    params.require(:triage).permit(:status, :notes)
  end
end
