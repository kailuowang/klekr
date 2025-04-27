class AddOAuthTokenColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :collectors, :access_token, :string
    add_column :collectors, :access_secret, :string
  end

end
