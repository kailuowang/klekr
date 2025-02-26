class FlickrStreamsController < ApplicationController
  include Collectr::PictureControllerHelper
  include Collectr::FlickrStreamsControllerHelper
  include Collectr::SlideshowControllerHelper
  before_action :authenticate, except: [:find]
  before_action :load_stream, only: [:show, :subscribe, :unsubscribe, :sync, :adjust_rating, :mark_all_as_read]

  def index
  end

  def my_sources
    respond_to do |format|
      format.json do
        begin
          streams = FlickrStream.collected_by(current_collector).includes(:monthly_scores)
          if params[:page].present?
            pagination_params = { 
              page: params[:page].to_i, 
              per_page: (params[:per_page] || 30).to_i 
            }
            streams = streams.paginate(pagination_params)
          end
          
          # Handle case where no streams exist yet
          if streams.empty?
            render json: []
          else
            data = data_for_streams(streams)
            render json: data
          end
        rescue => e
          Rails.logger.error("Error in my_sources: #{e.message}\n#{e.backtrace.join("\n")}")
          render json: { error: e.message }, status: 500
        end
      end
      format.yaml do
        begin
          render plain: FlickrStream.collected_by(current_collector).map(&:attributes).to_yaml, content_type: 'text/yaml'
        rescue => e
          Rails.logger.error("Error in my_sources yaml: #{e.message}")
          render plain: { error: e.message }.to_yaml, status: 500, content_type: 'text/yaml'
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.json{ render_json data_for_stream(@flickr_stream) }
      format.html do
        redirect_to find_flickr_streams_path(user_id: @flickr_stream.user_id, type: @flickr_stream.type)
      end
    end
  end

  def find
    slideshow_for_stream(find_stream)
  end

  def create
    permitted_params = params.permit(:user_id, :username, :type)
    opts = permitted_params.to_h.merge(collector: current_collector)
    new_stream = FlickrStream.find_or_create(opts)
    new_stream.subscribe
    render_json data_for_stream(new_stream)
  end

  def subscribe
    unless @flickr_stream.collecting?
      @flickr_stream.subscribe
      @flickr_stream.set_as_synced
    end
    show
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
    @flickr_stream ||= FlickrStream.find(params[:id].to_i)
    if(@flickr_stream.collector != current_collector)
      @flickr_stream = FlickrStream.find_or_create(user_id: @flickr_stream.user_id, collector: current_collector, type: @flickr_stream.type)
    end
  end

end
