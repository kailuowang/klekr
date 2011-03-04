class AddReadToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :viewed, :boolean, :default => false
  end

  def self.down
    remove_column :pictures, :viewed
  end
end
