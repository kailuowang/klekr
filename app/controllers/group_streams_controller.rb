class GroupStreamsController < ApplicationController
  before_filter :authenticate

  def index
    render_json Collectr::GroupsRetriever.new(current_collector).group_streams
  end
end