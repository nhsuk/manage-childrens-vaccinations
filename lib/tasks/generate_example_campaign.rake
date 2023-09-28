require "faker"
require "example_campaign_generator"

# Generate example campaign data.

desc <<DESC
Generates a random example campaign and writes it to stdout.

Option (set these as env vars, e.g. seed=42):
  seed: Random seed used to make data reproducible.
  presets: Use preset values for the following options. These can be overridden with patients_* options. Available presets:
    - model_office
  type: Type of campaign to generate, one of: hpv, flu

Options controlling number of patients to generate:
#{ExampleCampaignGenerator.patient_options.map { |option| "  #{option}" }.join("\n")}
DESC
task :generate_example_campaign, [] => :environment do |_task, _args|
  Faker::Config.locale = "en-GB"
  target_filename = "/dev/stdout"

  seed = ENV["seed"]&.to_i

  campaign_options = {}
  campaign_options[:type] = ENV
    .fetch("type") { campaign_options[:type] || :hpv }
    .to_sym
  campaign_options[:presets] = ENV["presets"] if ENV["presets"]
  ExampleCampaignGenerator.patient_options.each do |option|
    campaign_options[option] = ENV[option.to_s].to_i if ENV[option.to_s]
  end

  generator = ExampleCampaignGenerator.new(seed:, **campaign_options)
  data = generator.generate

  IO.write(target_filename, JSON.pretty_generate(data))
end
