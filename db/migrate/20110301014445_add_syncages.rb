class AddSyncages < ActiveRecord::Migration
  def self.up
    create_table :syncages do |t|
      t.references :picture
      t.references :flickr_stream, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :syncages
  end

end
