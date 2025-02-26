class CreatePictures < ActiveRecord::Migration[7.1][7.1]
  def up
    create_table :pictures do |t|
      t.string :secret
      t.string :title
      t.string :ref_url
      t.string :url

      t.timestamps
    end
  end

  def down
    drop_table :pictures
  end
end
