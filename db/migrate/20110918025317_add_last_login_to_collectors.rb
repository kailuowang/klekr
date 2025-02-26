class AddLastLoginToCollectors < ActiveRecord::Migration[7.1]
  def change
    add_column :collectors, :last_login, :datetime
  end
end
