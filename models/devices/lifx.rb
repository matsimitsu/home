module Devices
  class Lifx < ::Device

    def switch(state='on')
      RestClient::Request.execute(
        :method  => :put,
        :url     => "https://api.lifx.com/v1/lights/id:#{code}/state",
        :payload => {
          "power"    => state,
          "duration" => 5
        },
        :headers => {'Authorization' => "Bearer #{ENV['LIFX_KEY']}"}
      )
    end

  end
end
