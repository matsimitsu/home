require "sinatra"
require "sinatra/activerecord"

def require_folder(path)
  Dir[File.expand_path("../#{path}/**/*.rb", __FILE__)].each { |file| require file }
end

set :database, "sqlite3:///measurements.db"

require_folder("models")

get "/" do
  @electricity = Measurement.electricity.last_five_minutes.count
  @gas = Measurement.gas.last_five_minutes.count
  @water = Measurement.water.last_five_minutes.count

  haml :index
end



helpers do
  def format_gas(number)
    (number.to_f / 100).round(2)
  end
end
