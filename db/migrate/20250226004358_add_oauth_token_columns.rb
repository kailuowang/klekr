class AddOauthTokenColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :collectors, :oauth_token, :string
    add_column :collectors, :oauth_token_secret, :string
  end
end