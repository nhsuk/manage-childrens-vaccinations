source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"
gem "rails", "~> 7.1.2"

gem "aasm"
gem "audited"
gem "avo"
gem "awesome_print"
gem "bootsnap", require: false
gem "config"
gem "cssbundling-rails"
gem "devise"
gem "devise-pwned_password"
gem "faker", github: "misaka/faker", branch: "add_alternative_name"
gem "fhir_client"
gem "flipper"
gem "flipper-active_record"
gem "good_job"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "jbuilder"
gem "jsbundling-rails"
gem "jsonb_accessor"
gem "mail-notify"
gem "okcomputer"
gem "pg", "~> 1.5"
gem "propshaft"
gem "puma", "~> 6.4"
gem "pundit"
gem "sentry-rails"
gem "sentry-ruby"
gem "silencer", require: false
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "uk_postcode"
gem "wicked"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "pry-rails"
  gem "rspec-rails"
end

group :development do
  gem "aasm-diagram"
  gem "annotate", require: false
  gem "asciidoctor"
  gem "asciidoctor-diagram"
  gem "dockerfile-rails", ">= 1.0.0"
  gem "prettier_print", require: false
  gem "rails-erd"
  gem "rladr"
  gem "rubocop-govuk", require: false
  gem "solargraph", require: false
  gem "solargraph-rails", require: false
  gem "syntax_tree", require: false
  gem "syntax_tree-haml", require: false
  gem "syntax_tree-rbs", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "rspec"
  gem "shoulda-matchers"
  gem "timecop"
  gem "webmock"
end
