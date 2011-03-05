class AddOwnerNameToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :owner_name, :string
  end

  def self.down
    remove_column :pictures, :owner_name
  end
end
