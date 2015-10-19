class Weather

  def self.get_rain_forecast(lat, lng)
    response = RestClient.get("http://gps.buienradar.nl/getrr.php?lat=#{lat}&lon=#{lng}")
    [].tap do |arr|
      first = Time.parse(response.lines.first.split('|').last)
      response.lines.each_with_index do |line, index|
        rainfall = line.split('|').first
        time = first.advance(:minutes => (5 * index))
        arr.push({'ts' => time.utc, 'count' => rainfall.to_i})
      end
    end
  end

  def self.forecast(key, lat, lng)
    response = RestClient.get("https://api.forecast.io/forecast/#{key}/#{lat},#{lng}?units=si")
    JSON.parse(response)
  end

end


