class CollectorsController < ApplicationController
  before_filter :authenticate

  def info
    render_json( sources: @current_collector.flickr_streams.collecting.count,
                 pictures: @current_collector.pictures.unviewed.count,
                 collection: @current_collector.pictures.faved.count )
  end

end