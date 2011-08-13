class AddFavedAtToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :faved_at, :DateTime
  end
end
