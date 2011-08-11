class FlickrStreamsController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate, :load_stream

  # GET /flickr_streams
  # GET /flickr_streams.xml
  def index
    @flickr_streams =  FlickrStream.collected_by(current_collector).
                                    includes(:monthly_scores, :pictures).
                                    order('created_at DESC').
                                    paginate(page: params[:page])
    @number_of_new_pics = Picture.unviewed.collected_by(current_collector).count

    respond_to do |format|
      format.html
      format.yaml  { render :text => FlickrStream.collected_by(current_collector).map(&:attributes).to_yaml, :content_type => 'text/yaml' }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to action: :flickr_stream, controller: :slideshow, id: params[:id] }
    end
  end

  def subscribe
    @flickr_stream.subscribe
    render_json([])
  end

  def unsubscribe
    @flickr_stream.unsubscribe
    render_json([])
  end

  def pictures
    page = params[:page] ? params[:page].to_i : 1
    per_page = params[:num] ? params[:num].to_i : 1
    render_json_pictures @flickr_stream.get_pictures(per_page, page)
  end


  #GET /flickr_stream/1/sync
  def sync
    respond_to do |format|
      synced = @flickr_stream.sync(@flickr_stream.last_sync, params[:num_of_pics].try(:to_i))
      format.html { redirect_to(:back, :notice => "#{synced} new pictures were synced from #{@flickr_stream} @#{DateTime.now.to_s(:short)} " ) }
      format.xml  { head :ok }
    end
  end

  #PUT /flickr_stream/1/bump_rating
  def adjust_rating
    respond_to do |format|
      params[:adjustment] == 'up' ? @flickr_stream.bump_rating : @flickr_stream.trash_rating
      format.html { redirect_to(:back) }
      format.xml  { head :ok }
    end
  end

  #PUT /flickr_stream/1/mark_all_as_read
  def mark_all_as_read
    @flickr_stream.mark_all_as_read
    render_json([])
  end

  #POST /flickr_streams/import
  def import
    num_of_imports = FlickrStream.import( YAML.load( params[:streams_yaml].read ), current_collector)
    respond_to do |format|
      format.html { redirect_to(flickr_streams_path, :notice => "#{num_of_imports} subscriptions have been imported") }
      format.xml  { head :ok }
    end
  end

  #Get /flickr_streams/sync_all
  def sync_all
    respond_to do |format|
      FlickrStream.delay.sync_all(current_collector)
      format.html { redirect_to(flickr_streams_path, :notice => "All collections are scheduled to be refreshed shortly") }
      format.xml  { head :ok }
    end
  end


  # DELETE /flickr_streams/1
  # DELETE /flickr_streams/1.xml
  def destroy
    @flickr_stream = FlickrStream.find(params[:id])
    @flickr_stream.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

  private
  def load_stream
    @flickr_stream = FlickrStream.find(params[:id].to_i) if params[:id]
  end
end
