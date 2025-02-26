class CreateFaveStreams < ActiveRecord::Migration[7.1]
  def up
    create_table :fave_streams do |t|
      t.string :user_id
      t.datetime :last_sync

      t.timestamps
    end
  end

  def down
    drop_table :fave_streams
  end
end
