class AddSyncages < ActiveRecord::Migration[7.1]
  def up
    create_table :syncages do |t|
      t.references :picture
      t.references :flickr_stream, :polymorphic => true

      t.timestamps
    end
  end

  def down
    drop_table :syncages
  end

end
