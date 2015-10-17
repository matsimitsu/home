class CreateTimers < ActiveRecord::Migration
 def up
   create_table :timers do |t|
     t.datetime :event_run_at
   end
 end

  def down
    drop_table :timers
  end
end
