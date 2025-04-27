class AddCollectionSyncedToCollectors < ActiveRecord::Migration[7.1]
  def change
    add_column :collectors, :collection_synced, :boolean, default: false
  end
end
