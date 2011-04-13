class Collector < ActiveRecord::Base
  has_many :flickr_streams
  has_many :pictures

end