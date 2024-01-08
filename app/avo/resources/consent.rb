class Avo::Resources::Consent < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   query.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  def fields
    field :id, as: :id
    # Fields generated from the model
    field :patient_id, as: :number
    field :campaign_id, as: :number
    field :parent_name, as: :textarea
    field :parent_relationship,
          as: :select,
          enum: ::Consent.parent_relationships
    field :parent_relationship_other, as: :textarea
    field :parent_email, as: :textarea
    field :parent_phone, as: :textarea
    field :parent_contact_method, as: :number
    field :parent_contact_method_other, as: :textarea
    field :response, as: :select, enum: ::Consent.responses
    field :reason_for_refusal, as: :select, enum: ::Consent.reason_for_refusals
    field :reason_for_refusal_other, as: :textarea
    field :route, as: :select, enum: ::Consent.routes
    field :health_answers, as: :code, language: "javascript", only_on: :edit
    field :health_answers, as: :code, language: "javascript" do |record|
      if record.health_answers.present?
        JSON.pretty_generate(record.health_answers.as_json)
      end
    end
    field :patient, as: :belongs_to
    field :campaign, as: :belongs_to
    field :recorded_at, as: :date_time
    # add fields here
    field :consent_form, as: :has_many
  end
end
