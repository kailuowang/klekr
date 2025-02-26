class AddMonthlyScores < ActiveRecord::Migration[7.1]
  def up
     create_table :monthly_scores do |t|
       t.integer :month
       t.integer :year
       t.integer :score, default: 0
       t.integer :num_of_pics, default: 0
       t.references :flickr_stream, :polymorphic => true

       t.timestamps
     end
   end

   def down
     drop_table :monthly_scores
   end

end
