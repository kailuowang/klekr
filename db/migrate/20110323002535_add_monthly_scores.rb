class AddMonthlyScores < ActiveRecord::Migration
  def self.up
     create_table :monthly_scores do |t|
       t.integer :month
       t.integer :year
       t.integer :score, default: 0
       t.integer :num_of_pics, default: 0
       t.references :flickr_stream, :polymorphic => true

       t.timestamps
     end
   end

   def self.down
     drop_table :monthly_scores
   end

end
