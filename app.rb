require "sinatra"
require "sinatra/activerecord"
require 'sinatra/assetpack'
require 'sass'
require 'compass'
require 'sinatra/support'

def require_folder(path)
  Dir[File.expand_path("../#{path}/**/*.rb", __FILE__)].each { |file| require file }
end

set :root, File.dirname(__FILE__)
set :database, "sqlite3:///measurements.db"

require_folder("models")

register Sinatra::AssetPack
register Sinatra::CompassSupport

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

get "/api/:kind/:timeframe" do
  timeframe = params[:timeframe] || 'hour'
  halt 404 unless TIMEFRAMES.keys.include? timeframe
  Measurement.
    select("count(*) as count, created_at, strftime('#{TIMEFRAMES[timeframe]}', created_at) as ts").
    where(:kind => params[:kind]).
    in_last(1.send(timeframe.to_sym)).
    group('ts').
    to_json(:only => [:created_at, :count])
end

helpers do
  def format_gas(number)
    (number.to_f / 100).round(2)
  end
end

assets do
  js :application, [
    '/js/jquery.js',
    '/js/d3.js',
    '/js/*.js'
  ]

  css :application, [
    '/css/*.css'
   ]
end
