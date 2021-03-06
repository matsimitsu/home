require "sinatra"
require "sinatra/activerecord"
require 'sinatra/assetpack'
require 'sass'
require 'compass'
require 'sinatra/support'
require 'ns'
require 'rest-client'

ActiveRecord::Base.default_timezone = :utc

Ns.configure do |config|
  config.username = ENV['NS_API_USER']
  config.password = ENV['NS_API_PASS']
end

def require_folder(path)
  Dir[File.expand_path("../#{path}/*.rb", __FILE__)].each { |file| load file }
end

set :root, File.dirname(__FILE__)

require_folder("models")
require_folder("models/devices")

register Sinatra::AssetPack
register Sinatra::CompassSupport

get "/" do
  @electricity = Measurement.electricity.in_last(1.day.ago).count
  @gas = Measurement.gas.in_last(1.day.ago).count
  @water = Measurement.water.in_last(1.day.ago).count / 2

  haml :index
end

get "/devices" do
  @devices = Device.all
  haml :devices
end

get "/departures" do
  @departures = Ns::DepartureCollection.new(:station => 'klp').departures
  disruptions = Ns::DisruptionCollection.new(station: 'klp', :actual => true, :include_planned => true)
  @disruptions = disruptions.planned_disruptions
  haml :departures
end

get "/api/departures/:station" do
  Ns::DepartureCollection.new(:station => params[:station]).departures.to_json
end

get "/api/disruptions/:station" do
  disruptions = Ns::DisruptionCollection.new(station: params[:station])
  {
    :planned => disruptions.planned_disruptions,
    :unplanned => disruptions.unplanned_disruptions
  }.to_json
end

get "/api/meters" do
  {
    :electricity => (Measurement.electricity.last_five_minutes.count.to_f / 5).round(2),
    :gas => (Measurement.gas.last_five_minutes.count.to_f / 5).round(2),
    :water => (Measurement.water.last_five_minutes.count.to_f / 10).round(2)
  }.to_json
end

get "/api/devices" do
  Device.all.to_json
end

get "/api/devices/:id/:state" do
  device = Device.find(params[:id])
  device.switch(params[:state])
  device.to_json
end

get "/api/graphs/:kind/:timeframe" do
  timeframe = Timeframe.new(params[:timeframe])
  data= Measurement.
    select("count(*) as count, DATE_FORMAT(created_at, '#{timeframe.time_format}') as ts").
    where(:kind => params[:kind]).
    in_last(timeframe.rounded_from).
    group('ts').
    map do |i|
      {
        'ts' => i['ts'],
        'count' => params[:kind] == 'w' ? (i['count'] / 2) : i['count']
      }
    end

  {
    :from => timeframe.rounded_from.utc,
    :to => timeframe.rounded_to.utc,
    :timeframe => params[:timeframe],
    :data => data,
    :total => data.sum { |i| i['count'] }
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
    '/js/moment.js',
    '/js/*.js'
  ]

  css :application, [
    '/css/*.css'
   ]
end
