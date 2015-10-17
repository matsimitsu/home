module Devices
  class Blokker < ::Device

    def switch(state='on')
      system "sudo #{type.downcase} #{code} #{state}"
    end

  end
end
