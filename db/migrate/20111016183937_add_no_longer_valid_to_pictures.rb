class AddNoLongerValidToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :no_longer_valid, :boolean
  end
end
