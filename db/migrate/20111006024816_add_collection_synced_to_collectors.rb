class AddCollectionSyncedToCollectors < ActiveRecord::Migration
  def change
    add_column :collectors, :collection_synced, :boolean, default: false
  end
end
