class Device < ActiveRecord::Base

  def switch(state='on')
    system "#{kind} #{code} #{state}"
  end

end
