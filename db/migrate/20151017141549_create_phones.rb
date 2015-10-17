class CreatePhones < ActiveRecord::Migration
 def up
   create_table :phones do |t|
     t.string :mac
     t.datetime :last_seen_at
     t.string :name
   end
 end

  def down
    drop_table :phones
  end
end
