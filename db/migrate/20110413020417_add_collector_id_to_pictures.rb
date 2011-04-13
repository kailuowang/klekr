class AddCollectorIdToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :collector_id, :integer
    add_index :pictures, :collector_id
  end

  def self.down
    remove_index :pictures, :collector_id
    remove_column :pictures, :collector_id
  end
end
