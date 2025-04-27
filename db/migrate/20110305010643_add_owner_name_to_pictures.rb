class AddOwnerNameToPictures < ActiveRecord::Migration[7.1]
  def up
    add_column :pictures, :owner_name, :string
  end

  def down
    remove_column :pictures, :owner_name
  end
end
