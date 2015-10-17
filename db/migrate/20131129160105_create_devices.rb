class CreateDevices < ActiveRecord::Migration
  def up
    create_table :devices do |t|
      t.string :type
      t.string :name
      t.string :icon
      t.string :code
    end
  end

  def down
    drop_table :devices
  end
end
