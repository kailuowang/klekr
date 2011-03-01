class Syncage < ActiveRecord::Base
  extend Collectr::FindOrCreate

  belongs_to :picture
  belongs_to :flickr_stream

end