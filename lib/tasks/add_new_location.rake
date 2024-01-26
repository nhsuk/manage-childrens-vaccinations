require "readline"

desc <<-DESC
  Add a new location
  Usage:
    rake add_new_location  # You will be prompted for location info
    rake add_new_location[name,address,town,county,postcode,team_id]
DESC
task :add_new_location,
     %i[name address town county postcode team_id] =>
       :environment do |_task, args|
  if args.to_a.empty? && $stdin.isatty && $stdout.isatty
    name = prompt_user_for "name", required: true
    address = prompt_user_for "address"
    town = prompt_user_for "town"
    county = prompt_user_for "county"
    postcode = prompt_user_for "postcode", required: true
    team_id = prompt_user_for "team_id", required: true
  elsif args.to_a.size == 6
    name = args[:name]
    address = args[:address]
    town = args[:town]
    county = args[:county]
    postcode = args[:postcode]
    team_id = args[:team_id]
  elsif args.to_a.size != 4
    raise "Expected 6 arguments got #{args.to_a.size}"
  end

  Location.create!(
    name:,
    address:,
    town:,
    county:,
    postcode:,
    team_id:,
    registration_open: true
  )

  puts "Location #{name} added to team #{Team.find(team_id).name}."
end

def prompt_user_for(prompt, required: false)
  response = nil
  loop do
    response = Readline.readline "#{prompt}> ", true
    if required && response.blank?
      puts "#{prompt} cannot be blank"
    else
      break
    end
  end
  response
end
