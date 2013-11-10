#!/usr/bin/env ruby
$LOAD_PATH << '.'

require 'em-serialport'
require 'json'
require 'app'

# Silence sql query logging
ActiveRecord::Base.logger.level = 1

EM.run do
  str = ''
  serial = EventMachine.open_serial('/dev/ttyACM0', 9600, 8, 1, 0)
  serial.on_data do |data|
    puts data
    kind = /[a-z]/.match(data).to_s
    if kind.present?
      Measurement.create(
        :kind => kind.force_encoding(Encoding::UTF_8)
      )
      puts kind
    end
  end
end
