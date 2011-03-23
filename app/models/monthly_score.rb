class MonthlyScore < ActiveRecord::Base
  belongs_to :flickr_stream

  scope :by_month_stream, lambda { |date, stream| where(month: date.month, year: date.year, flickr_stream_id: stream.id).limit(1) }

  def add to_add
    update_attribute( :score, score + to_add )
  end

  def add_num_of_pics to_add
    update_attribute( :num_of_pics, num_of_pics  + to_add )
  end
end