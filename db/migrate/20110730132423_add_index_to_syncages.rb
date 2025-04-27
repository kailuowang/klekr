class AddIndexToSyncages < ActiveRecord::Migration[7.1]
  def change
    add_index :syncages, [:picture_id, :flickr_stream_id]
  end
end
