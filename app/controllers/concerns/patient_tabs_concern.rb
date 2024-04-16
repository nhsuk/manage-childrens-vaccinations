module PatientTabsConcern
  extend ActiveSupport::Concern

  def group_patient_sessions_by_conditions(all_patient_sessions, tab_conditions)
    all_patient_sessions.group_by do |patient_session|
      tab_conditions
        .find { |_, conditions| conditions.any? { patient_session.send(_1) } }
        &.first
    end
  end

  def group_patient_sessions_by_state(all_patient_sessions, tab_states)
    all_patient_sessions.group_by do |patient_session|
      tab_states.find { |_, states| patient_session.state.in? states }&.first
    end
  end

  def count_patient_sessions(tab_patient_sessions, tabs)
    tab_patient_sessions
      .transform_values(&:count)
      .tap { |tab_counts| tabs.each { |tab| tab_counts[tab] ||= 0 } }
  end
end
