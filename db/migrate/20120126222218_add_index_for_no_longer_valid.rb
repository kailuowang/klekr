class AddIndexForNoLongerValid < ActiveRecord::Migration
  def change
    add_index :pictures, :no_longer_valid
  end
end
