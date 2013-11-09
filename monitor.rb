#!/usr/bin/env ruby
$LOAD_PATH << '.'

require 'em-serialport'
require 'json'
require 'app'

EM.run do
  str = ''
  serial = EventMachine.open_serial('/dev/ttyACM0', 9600, 8, 1, 0)
  serial.on_data do |data|
    kind = /[a-z]/.match(data).to_s
    if kind.present?
      Measurement.create(:kind => kind)
      puts kind
    end
  end
end
