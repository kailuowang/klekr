class FlickrStreamsController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate, :load_stream

  def index
    @sources_path = my_sources_flickr_streams_path
    @contacts_path = contacts_users_path
    @import_contact_path = flickr_streams_path
  end

  def my_sources
    respond_to do |format|
      format.js do
        streams = FlickrStream.collected_by(current_collector).includes(:monthly_scores)
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
    Collectr::ContactsImporter.new(@current_collector).import(params)
    js_ok
  end

  def subscribe
    @flickr_stream.subscribe
    js_ok
  end

  def unsubscribe
    @flickr_stream.unsubscribe
    js_ok
  end

  def pictures
    page = params[:page] ? params[:page].to_i : 1
    per_page = params[:num] ? params[:num].to_i : 1
    render_json_pictures @flickr_stream.get_pictures(per_page, page)
  end


  #GET /flickr_stream/1/sync
  def sync
    respond_to do |format|
      synced = @flickr_stream.sync
      format.html { redirect_to(:back, :notice => "#{synced} new pictures were synced from #{@flickr_stream} @#{DateTime.now.to_s(:short)} " ) }
    end
  end

  #PUT /flickr_stream/1/bump_rating
  def adjust_rating
    respond_to do |format|
      params[:adjustment] == 'up' ? @flickr_stream.bump_rating : @flickr_stream.trash_rating
      js_ok
    end
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
    @flickr_stream = FlickrStream.find(params[:id].to_i) if params[:id]
  end

  def data_for_streams(streams)
    streams.map do |stream|
      {
        id: stream.id,
        iconUrl: stream.icon_url,
        ownerName: stream.username,
        type: stream.type_display,
        slideUrl: flickr_stream_path(stream),
        rating: stream.star_rating
      }
    end
  end
end
