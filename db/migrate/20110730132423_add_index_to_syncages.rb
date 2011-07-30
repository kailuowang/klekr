class AddIndexToSyncages < ActiveRecord::Migration
  def change
    add_index :syncages, [:picture_id, :flickr_stream_id]
  end
end
