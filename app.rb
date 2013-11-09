require "sinatra"
require "sinatra/activerecord"

def require_folder(path)
  Dir[File.expand_path("../#{path}/**/*.rb", __FILE__)].each { |file| require file }
end

set :database, "sqlite3:///measurements.db"

require_folder("models")
