class FlickrStreamsController < ApplicationController
  include Collectr::PictureControllerHelper
  include Collectr::FlickrStreamsControllerHelper

  before_filter :authenticate, :load_stream, except: [:show]

  def index
  end

  def my_sources
    respond_to do |format|
      format.json do
        streams = FlickrStream.collected_by(current_collector).includes(:monthly_scores)
        streams = streams.paginate(params.slice(:page, :per_page)) if params[:page].present?
        render json: data_for_streams(streams)
      end
      format.yaml do
        render :text => FlickrStream.collected_by(current_collector).map(&:attributes).to_yaml, :content_type => 'text/yaml'
      end
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to action: :flickr_stream, controller: :slideshow, id: params[:id] }
    end
  end

  def create
    new_streams = Collectr::ContactsImporter.new(@current_collector).import(params)
    render_json data_for_streams(new_streams)
  end

  def subscribe
    @flickr_stream.subscribe
    @flickr_stream.set_as_synced
    render_json data_for_stream(@flickr_stream)
  end

  def unsubscribe
    @flickr_stream.unsubscribe
    render_json data_for_stream(@flickr_stream)
  end

  #PUT /flickr_stream/1/sync
  def sync
    @flickr_stream.sync
    js_ok
  end

  def sync_many
    FlickrStream.find(params[:ids]).each(&:sync)
    js_ok
  end

  #PUT /flickr_stream/1/adjust_rating
  def adjust_rating
    params[:adjustment] == 'up' ? @flickr_stream.bump_rating : @flickr_stream.trash_rating
    render_json @flickr_stream.star_rating
  end

  #PUT /flickr_stream/1/mark_all_as_read
  def mark_all_as_read
    @flickr_stream.mark_all_as_read
    js_ok
  end

  #POST /flickr_streams/import
  def import
    num_of_imports = FlickrStream.import( YAML.load( params[:streams_yaml].read ), current_collector)
    respond_to do |format|
      format.html { redirect_to(flickr_streams_path, :notice => "#{num_of_imports} subscriptions have been imported") }
    end
  end

  private
  def load_stream
    unless @flickr_stream
      @flickr_stream = FlickrStream.find(params[:id].to_i) if params[:id]
      if(@flickr_stream && @flickr_stream.collector != current_collector)
        raise ActionController::RoutingError.new('Access not permitted')
      end
    end
  end

end
