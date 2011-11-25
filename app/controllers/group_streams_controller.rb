class GroupStreamsController < ApplicationController
  include Collectr::FlickrStreamsControllerHelper

  before_filter :authenticate


  def index
    render_json data_for_streams(Collectr::GroupsRetriever.new(current_collector).group_streams)
  end
end