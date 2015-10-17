module Devices
  class Blokker < ::Device

    def switch(state='on')
      system "sudo #{kind} #{code} #{state}"
    end

  end
end
