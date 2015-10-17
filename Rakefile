require "./app"
require "sinatra/activerecord/rake"

task :update_phones do
  Phone.update_seen
end

task :update_sunset do
  response =  RestClient.get("http://api.sunrise-sunset.org/json?lat=52.0263009&lng=-5.5544309&date=today&formatted=0")
  json = JSON.parse(response.body)

  sunset = Time.parse(json['results']['sunset'])

  puts sunset
end

task :run_events do
  current_run_at = Time.now.utc
  last_run_at    = Timer.current.event_run_at || 10.minutes.ago.utc
  Event.where('run_at > ? <= ?', last_run_at, current_run_at).each do |event|
  end

  Timer.current.update_attribute(:event_run_at, current_run_at)
end
