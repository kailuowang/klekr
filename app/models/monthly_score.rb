class MonthlyScore < ActiveRecord::Base
  belongs_to :flickr_stream

  scope :by_month_stream, lambda { |date, stream| where(month: date.month, year: date.year, flickr_stream_id: stream.id).limit(1) }

  def add to_add
    update_attribute( :score, score + to_add )
  end

  def add_num_of_pics to_add
    update_attribute( :num_of_pics, num_of_pics  + to_add )
  end

  def weight
    months_from_now = months_from(Date.today)
    months_from_now > 2 ? 1 / Math.log2(months_from_now) : 1
  end

  def weighted_rating
    (score * weight).to_f / num_of_pics
  end

  private


  def months_from(date)
    date.month - month + (date.year - year ) * 12
  end

end