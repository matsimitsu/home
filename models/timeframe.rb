class Timeframe

  TIMEFRAMES = {
    'hour' => '%Y-%m-%dT%H:%i:00Z',
    'day' => '%Y-%m-%dT%H:00:00Z',
    'week' => '%Y-%m-%dT%H:00:00Z',
    'month' => '%Y-%m-%dT00:00:00Z',
    'year' => '%Y-%m-%dT00:00:00Z'
  }

  attr_reader :from, :to, :timeframe

  def initialize(timeframe)
    @from      = 1.send(timeframe).ago
    @to        = Time.now
    @timeframe = timeframe
  end

  def time_format
    TIMEFRAMES[timeframe]
  end

  def rounded_from
    case timeframe
    when 'hour'
      from.change(:sec => 0)
    when 'day'
      from.beginning_of_hour
    when 'week'
      from.beginning_of_hour
    when'month'
      from.beginning_of_day
    when 'year'
      from.beginning_of_day
    end
  end

  def rounded_to
    case timeframe
    when 'hour'
      to.change(:sec => 59)
    when 'day'
      to.end_of_hour
    when 'week'
      to.end_of_hour
    when 'month'
      to.end_of_day
    when 'year'
      to.end_of_day
    end
  end

end
