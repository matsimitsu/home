require "sinatra"
require "sinatra/activerecord"

def require_folder(path)
  Dir[File.expand_path("../#{path}/**/*.rb", __FILE__)].each { |file| require file }
end

set :database, "sqlite3:///measurements.db"
require_folder("models")

TIMEFRAMES = {
  'hour' => '%Y%m%d%H%M',
  'day' => '%Y%m%d%H',
  'week' => '%Y%m%d%H',
  'month' => '%Y%m%d',
  'year' => '%Y%m%d'
}

get "/" do
  @electricity = (Measurement.electricity.last_five_minutes.count.to_f / 5).round(2)
  @gas = (Measurement.gas.last_five_minutes.count.to_f / 5).round(2)
  @water = (Measurement.water.last_five_minutes.count.to_f / 5).round(2)

  haml :index
end

get "/graphs/:kind/:timeframe" do
  timeframe = params[:timeframe] || 'hour'
  head :not_found unless TIMEFRAMES.keys.include? timeframe
  Measurement.
    select("count(*) as count, strftime('#{TIMEFRAMES[timeframe]}', created_at) as ts").
    where(:kind => params[:kind]).
    in_last(1.send(timeframe.to_sym)).
    group('ts').
    to_json(:only => [:ts, :count])
end


helpers do
  def format_gas(number)
    (number.to_f / 100).round(2)
  end
end


