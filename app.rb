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

require_folder("models")

register Sinatra::AssetPack
register Sinatra::CompassSupport

get "/" do
  @electricity = (Measurement.electricity.last_five_minutes.count.to_f / 5).round(2)
  @gas = (Measurement.gas.last_five_minutes.count.to_f / 5).round(2)
  @water = (Measurement.water.last_five_minutes.count.to_f / 5).round(2)

  haml :index
end

get "/api/:kind/:timeframe" do
  timeframe = Timeframe.new(params[:timeframe])
  {
    :from => timeframe.rounded_from,
    :to => timeframe.rounded_to,
    :timeframe => params[:timeframe],
    :data => Measurement.
      select("count(*) as count, strftime('#{timeframe.time_format}', created_at) as ts").
      where(:kind => params[:kind]).
      in_last(timeframe.rounded_from).
      group('ts').
      map { |i| {'ts' => i['ts'], 'count' => i['count']} }
  }.to_json
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
