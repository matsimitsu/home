module Devices
  class All < ::Device

    def switch(state='on')
      Device.all.each do |device|
        device.switch(state)
      end
    end

  end
end
