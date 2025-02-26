class ChangeDefaultCollectingForStream < ActiveRecord::Migration[7.1]
  def change
    change_column_default :flickr_streams, :collecting,  false
  end

end
