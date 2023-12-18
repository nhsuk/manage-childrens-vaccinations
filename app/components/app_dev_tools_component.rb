class AppDevToolsComponent < ViewComponent::Base
  erb_template <<-ERB
    <% unless Rails.env.production? %>
      <div class="app-dev-tools">
        <div class="nhsuk-width-container">
          <h2 class="nhsuk-heading-s">
            Development tools
            <span class="nhsuk-caption-m">Only available in non-production environments</span>
          </h2>
          <%= content %>
        </div>
      </div>
    <% end %>
  ERB

  def render?
    !Rails.env.production?
  end
end
