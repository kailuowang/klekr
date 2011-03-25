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
    if(months_from_now == 0)
       Date.today.day.to_f / days_in_month(Date.today.year, Date.today.month)
    elsif months_from_now <= 2
      1
    else
      1 / Math.log2(months_from_now)
    end
  end

  def weighted_rating
    return 0 if num_of_pics == 0
    (score * weight).to_f / num_of_pics
  end

  private

  def months_from(date)
    date.month - month + (date.year - year ) * 12
  end

  def days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end


end