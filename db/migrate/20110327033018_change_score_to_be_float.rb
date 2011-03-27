class ChangeScoreToBeFloat < ActiveRecord::Migration
  def self.up
    change_column :monthly_scores, :score, :float
  end

  def self.down
    change_column :monthly_scores, :score, :integer
  end
end
