class ExampleCampaignData
  def initialize(data_file:)
    @data_file = data_file
  end

  def raw_data
    @raw_data ||= JSON.parse(File.read(@data_file))
  end

  def vaccine_attributes
    raw_data["vaccines"].map do |vaccine|
      {
        type: raw_data["type"],
        brand: vaccine["brand"],
        method: vaccine["method"].downcase,
        batches: vaccine["batches"]
      }
    end
  end

  def campaign_attributes
    { name: raw_data["type"] }
  end

  def session_attributes
    { date: raw_data["date"], name: raw_data["title"] }
  end

  def campaign_location_name
    raw_data["location"]
  end

  def sessions
    if raw_data.key? "sessions"
      raw_data["sessions"].map do |session_data|
        session_data.merge("school" => school_attributes(session_data))
      end
    else
      {
        "date" => raw_data["date"],
        "location" => raw_data["location"],
        "school" => school_attributes(raw_data),
        "patients" => raw_data["patients"]
      }
    end
  end

  def school_attributes(session_data)
    school_data = session_data["school"]
    {
      name: school_data["name"],
      address: school_data["address"],
      locality: school_data["locality"],
      town: school_data["town"],
      county: school_data["county"],
      postcode: school_data["postcode"],
      url: school_data["url"]
    }
  end

  def health_question_attributes
    return [] if raw_data["healthQuestions"].blank?

    raw_data["healthQuestions"].map do |hq|
      hq.slice(
        "id",
        "question",
        "hint",
        "next_question",
        "follow_up_question"
      ).with_indifferent_access
    end
  end

  def children_attributes(session_attributes: nil)
    session_attributes ||= raw_data
    session_attributes["patients"].map do |patient|
      attributes = {
        seen: patient.dig("seen", "text"),
        first_name: patient["firstName"],
        last_name: patient["lastName"],
        dob: patient["dob"],
        sex: patient["sex"],
        consents: patient["consents"],
        nhs_number: patient["nhsNumber"],
        screening: patient["screening"],
        parent_name: patient["parentName"],
        parent_relationship: patient["parentRelationship"],
        parent_relationship_other: patient["parentRelationshipOther"],
        parent_email: patient["parentEmail"],
        parent_phone: patient["parentPhone"],
        parent_info_source: patient["parentInfoSource"]
      }

      if patient["triage"].present?
        attributes[:triage] = {
          status: patient["triage"]["status"],
          notes: patient["triage"]["notes"],
          user_email: patient["triage"]["user_email"]
        }
      end

      if patient["consents"].present?
        patient["consents"].map! do |consent_example|
          consent = {}

          consent[:response] = consent_example["response"]
          consent[:reason_for_refusal] = consent_example["reasonForRefusal"]
          consent[:reason_for_refusal_other] = consent_example[
            "reasonForRefusalOtherReason"
          ]

          consent[:childs_name] = consent_example["childsName"]
          consent[:date_of_birth] = consent_example["childsDob"]
          consent[:common_name] = consent_example["childsCommonName"]

          consent[:address_line_1] = consent_example["addressLine1"]
          consent[:address_line_2] = consent_example["addressLine2"]
          consent[:address_postcode] = consent_example["addressPostcode"]
          consent[:address_town] = consent_example["addressTown"]

          consent[:parent_name] = consent_example["parentName"]
          consent[:parent_relationship] = consent_example["parentRelationship"]
          consent[:parent_relationship_other] = consent_example[
            "parentRelationshipOther"
          ]
          consent[:parent_email] = consent_example["parentEmail"]
          consent[:parent_phone] = consent_example["parentPhone"]
          consent[:parent_contact_method] = consent_example[
            "parentContactMethod"
          ]
          consent[:parent_contact_method_other] = consent_example[
            "parentContactMethodOther"
          ]

          consent[:gp_response] = consent_example["gpResponse"]
          consent[:gp_name] = consent_example["gpName"]

          consent[:route] = consent_example["route"]

          consent[:health_answers] = consent_example[
            "healthQuestionResponses"
          ].map { HealthAnswer.new(_1) }

          consent
        end
      end

      attributes
    end
  end

  def team_attributes
    team_data = raw_data["team"]
    {
      name: team_data["name"],
      users:
        team_data["users"].map do |user|
          user.slice("full_name", "username", "email")
        end
    }.with_indifferent_access
  end

  def consent_form_attributes(session_attributes:)
    session_attributes["consent_forms"]
  end
end
