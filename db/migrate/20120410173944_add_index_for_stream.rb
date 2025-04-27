class AddIndexForStream < ActiveRecord::Migration[7.1]
  def change
    add_index :flickr_streams, [:collector_id, :user_id, :type],
              name: :index_find_existing_stream
  end
end
