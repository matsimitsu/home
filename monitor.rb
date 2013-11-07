require 'em-serialport'
require 'json'

EM.run do
  str = ''
  serial = EventMachine.open_serial('/dev/ttyACM0', 9600, 8, 1, 0)
  serial.on_data do |data|
    str << data
    if str.split('').last == "\n"
      puts str
      begin
        puts JSON.parse(str)
      rescue => e
        puts e.inspect
      end
      str = ''
    end
  end
end
