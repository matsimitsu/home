class Timer < ActiveRecord::Base

  def self.current
    first || create
  end

end
