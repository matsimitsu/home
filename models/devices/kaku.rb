module Devices
  class Kaku < ::Device

    def switch(state='on')
      system "sudo #{type.downcase} #{code} #{state}"
    end

  end
end
