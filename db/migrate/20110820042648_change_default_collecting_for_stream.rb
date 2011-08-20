class ChangeDefaultCollectingForStream < ActiveRecord::Migration
  def change
    change_column_default :flickr_streams, :collecting,  false
  end

end
