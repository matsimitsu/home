class CreateMeasurements < ActiveRecord::Migration
  def up
    create_table :measurements do |t|
      t.string :kind
      t.timestamps
    end
  end

  def down
    drop_table :measurements
  end
end
