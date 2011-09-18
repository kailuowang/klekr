class AddLastLoginToCollectors < ActiveRecord::Migration
  def change
    add_column :collectors, :last_login, :datetime
  end
end
