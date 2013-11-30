class Device < ActiveRecord::Base

  def switch(state='on')
    system "sudo #{kind} #{code} #{state}"
  end

end
