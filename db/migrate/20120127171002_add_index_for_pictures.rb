class AddIndexForPictures < ActiveRecord::Migration
  def change
    add_index :pictures, [:collector_id, :viewed, :stream_rating, :date_upload],
              order: { viewed: :desc, stream_rating: :desc, date_upload: :desc},
              name: :new_pictures_index
  end

end
