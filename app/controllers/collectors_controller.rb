class CollectorsController < ApplicationController
  before_filter :authenticate

  def info
    render_json( sources: @current_collector.flickr_streams.count,
                 pictures: @current_collector.pictures.unviewed.count)
  end

end