class AddOAuthTokenColumns < ActiveRecord::Migration
  def change
    add_column :collectors, :access_token, :string
    add_column :collectors, :access_secret, :string
  end

end
