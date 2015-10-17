module Devices
  class Kika < ::Device

    def switch(state='on')
      system "sudo #{kind} #{code} #{state}"
    end

  end
end
