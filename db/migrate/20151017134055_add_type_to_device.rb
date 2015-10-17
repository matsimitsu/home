class AddTypeToDevice < ActiveRecord::Migration
  def up
    add_column :devices, :type, :string
  end

  def down
  end
end
