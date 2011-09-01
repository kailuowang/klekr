class EditorRecommendationsController < ApplicationController
  include Collectr::FlickrStreamsControllerHelper
  before_filter :authenticate, :prepare_editor

  def create
    render_json data_for_streams(@editor.recommendation_streams_for(@current_collector))
  end

  def index
    render_json(data_for_streams( @editor.editor_streams ) )
  end

  private
  def prepare_editor
    @editor = Collectr::Editor.new()
  end
end