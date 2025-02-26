class AddFavedAtToPictures < ActiveRecord::Migration[7.1]
  def change
    add_column :pictures, :faved_at, :DateTime
  end
end
