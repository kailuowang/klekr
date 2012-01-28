class AddIndexForFavedPictures < ActiveRecord::Migration
  def change
    add_index :pictures, [:collector_id, :rating, :faved_at],
              order: {rating: :desc, faved_at: :desc},
              name: :index_faved_pictures
  end

end
