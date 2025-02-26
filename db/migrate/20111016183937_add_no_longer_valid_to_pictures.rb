class AddNoLongerValidToPictures < ActiveRecord::Migration[7.1]
  def change
    add_column :pictures, :no_longer_valid, :boolean
  end
end
