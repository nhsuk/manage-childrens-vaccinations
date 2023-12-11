module VaccinationsHelper
  def vaccination_date(datetime)
    date = datetime.to_date

    current_date = Time.zone.today

    if date == current_date
      "Today (#{date.to_fs(:nhsuk_date)})"
    elsif date == current_date - 1
      "Yesterday (#{date.to_fs(:nhsuk_date)})"
    else
      date.to_fs(:nhsuk_date)
    end
  end

  def vaccination_initial_delivery_sites
    %w[left_arm right_arm other]
  end

  def vaccination_delivery_methods
    methods = VaccinationRecord.delivery_methods.keys
    methods.map do |m|
      [m, VaccinationRecord.human_enum_name("delivery_methods", m)]
    end
  end

  def vaccination_delivery_sites
    sites =
      VaccinationRecord.delivery_sites.keys - vaccination_initial_delivery_sites
    sites.map do |s|
      [s, VaccinationRecord.human_enum_name("delivery_sites", s)]
    end
  end

  def in_tab_action_needed?(action, _outcome)
    action.in? %i[vaccinate get_consent triage follow_up check_refusal]
  end

  def in_tab_vaccinated?(_action, outcome)
    outcome.in? %i[vaccinated]
  end

  def in_tab_not_vaccinated?(_action, outcome)
    outcome.in? %i[do_not_vaccinate not_vaccinated]
  end
end
