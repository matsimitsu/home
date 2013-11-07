EM.run do
  serial = EventMachine.open_serial('/dev/ttyACM0', 9600, 8, 1, 0)
  serial.on_data do |data|
    puts data.inspect
  end
end
