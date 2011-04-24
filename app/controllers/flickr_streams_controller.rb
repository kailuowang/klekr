class FlickrStreamsController < ApplicationController

  before_filter :authenticate

  # GET /flickr_streams
  # GET /flickr_streams.xml
  def index
    @flickr_streams = FlickrStream.paginate( :page => params[:page], :order => 'created_at DESC',
                                             conditions: {collector_id: current_collector.id} )
    @number_of_new_pics = Picture.unviewed.collected_by(current_collector).count

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @flickr_streams }
      format.yaml  { render :text => @flickr_streams.map(&:attributes).to_yaml, :content_type => 'text/yaml' }
    end
  end


  # GET /flickr_streams/1/edit
  def edit
    @flickr_stream = FlickrStream.find(params[:id])
  end

  #GET /flickr_stream/1/sync
  def sync
    @flickr_stream = FlickrStream.find(params[:id])
    respond_to do |format|
      synced = @flickr_stream.sync(@flickr_stream.last_sync, params[:num_of_pics].try(:to_i))
      format.html { redirect_to(:back, :notice => "#{synced} new pictures were synced from #{@flickr_stream} @#{DateTime.now.to_s(:short)} " ) }
      format.xml  { head :ok }
    end
  end

  #PUT /flickr_stream/1/bump_rating
  def adjust_rating
    @flickr_stream = FlickrStream.find(params[:id])
    respond_to do |format|
      params[:adjustment] == 'up' ? @flickr_stream.bump_rating : @flickr_stream.trash_rating
      format.html { redirect_to(:back) }
      format.xml  { head :ok }
    end
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
end
