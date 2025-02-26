class EditorRecommendationsController < ApplicationController
  include Collectr::FlickrStreamsControllerHelper
  before_action :authenticate, :prepare_editor

  def index
    render_json data_for_streams(@editor.recommendation_streams_for(@current_collector))
  end

  private
  def prepare_editor
    @editor = Collectr::Editor.new()
  end
end