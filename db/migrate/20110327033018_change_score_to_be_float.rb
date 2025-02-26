class ChangeScoreToBeFloat < ActiveRecord::Migration[7.1]
  def up
    change_column :monthly_scores, :score, :float
  end

  def down
    change_column :monthly_scores, :score, :integer
  end
end
