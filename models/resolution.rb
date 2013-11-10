class Resolution

  TIMEFRAMES = {
    'hour' => '%Y-%m-%dT%H:%M:00',
    'day' => '%Y-%m-%dT%H:00:00',
    'week' => '%Y%-m%-dT%H:00:00',
    'month' => '%Y-%m-%dT00:00:00',
    'year' => '%Y%-m-%dT00:00:00'
  }

  attr_reader :from, :to, :timeframe

  def initialize(timeframe)
    @from = 1.send(timeframe).ago
    @to = Time.now
    @timeframe = timeframe
  end

  def time_format
    TIMEFRAMES[timeframe]
  end

  def rounded_from
    case timeframe
    when 'hour'
      from.change(:sec => 0)
    when 'day' || 'week'
      from.beginning_of_hour
    when 'year' || 'month'
      from.beginning_of_day
    end
  end

  def rounded_to
    case timeframe
    when 'hour'
      to.change(:sec => 59)
    when 'day' || 'week'
      to.end_of_hour
    when 'year' || 'month'
      to.end_of_day
    end
  end

end
