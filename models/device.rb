class Device < ActiveRecord::Base

  def switch(state='on')
    system "sudo #{kind} #{code} #{state}"
  end

  def kind
    self.class.name.split('::').last.downcase
  end

end
