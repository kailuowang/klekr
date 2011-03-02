class FlickrStreamsController < ApplicationController
  # GET /flickr_streams
  # GET /flickr_streams.xml
  def index
    @flickr_streams = FlickrStream.all

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @flickr_streams }
    end
  end

  # GET /flickr_streams/new
  # GET /flickr_streams/new.xml
  def new
    @flickr_stream = FlickrStream.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @flickr_stream }
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
      @flickr_stream.sync
      format.html { redirect_to(flickr_streams_path, :notice => "Fave stream was successfully synced @#{DateTime.now.to_s(:short)}") }
      format.xml  { head :ok }
    end
  end

  # POST /flickr_streams
  # POST /flickr_streams.xml
  def create
    @flickr_stream = FlickrStream.build(params[:flickr_stream])

    respond_to do |format|
      if @flickr_stream.save
        format.html { redirect_to( flickr_streams_path, :notice => 'Fave stream was successfully created.') }
        format.xml  { render :xml => @flickr_stream, :status => :created, :location => @flickr_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @flickr_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flickr_streams/1
  # PUT /flickr_streams/1.xml
  def update
    @flickr_stream = FlickrStream.find(params[:id])

    respond_to do |format|
      if @flickr_stream.update_attributes(params[:flickr_stream])
        format.html { redirect_to(flickr_streams_path, :notice => 'Fave stream was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @flickr_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /flickr_streams/1
  # DELETE /flickr_streams/1.xml
  def destroy
    @flickr_stream = FlickrStream.find(params[:id])
    @flickr_stream.destroy

    respond_to do |format|
      format.html { redirect_to(flickr_streams_url) }
      format.xml  { head :ok }
    end
  end
end
