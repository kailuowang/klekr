class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :secret
      t.string :title
      t.string :ref_url
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
