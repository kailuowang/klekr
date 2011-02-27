class FaveStreamsController < ApplicationController
  # GET /fave_streams
  # GET /fave_streams.xml
  def index
    @fave_streams = FaveStream.all

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @fave_streams }
    end
  end

  # GET /fave_streams/1
  # GET /fave_streams/1.xml
  def show
    @fave_stream = FaveStream.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @fave_stream }
    end
  end

  # GET /fave_streams/new
  # GET /fave_streams/new.xml
  def new
    @fave_stream = FaveStream.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fave_stream }
    end
  end

  # GET /fave_streams/1/edit
  def edit
    @fave_stream = FaveStream.find(params[:id])
  end

  #GET /fave_stream/1/sync
  def sync
    @fave_stream = FaveStream.find(params[:id])
    respond_to do |format|
      @fave_stream.sync
      format.html { redirect_to(fave_streams_path, :notice => 'Fave stream was successfully synced.') }
      format.xml  { head :ok }
    end
  end

  # POST /fave_streams
  # POST /fave_streams.xml
  def create
    @fave_stream = FaveStream.new(params[:fave_stream])

    respond_to do |format|
      if @fave_stream.save
        format.html { redirect_to(@fave_stream, :notice => 'Fave stream was successfully created.') }
        format.xml  { render :xml => @fave_stream, :status => :created, :location => @fave_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fave_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fave_streams/1
  # PUT /fave_streams/1.xml
  def update
    @fave_stream = FaveStream.find(params[:id])

    respond_to do |format|
      if @fave_stream.update_attributes(params[:fave_stream])
        format.html { redirect_to(@fave_stream, :notice => 'Fave stream was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fave_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fave_streams/1
  # DELETE /fave_streams/1.xml
  def destroy
    @fave_stream = FaveStream.find(params[:id])
    @fave_stream.destroy

    respond_to do |format|
      format.html { redirect_to(fave_streams_url) }
      format.xml  { head :ok }
    end
  end
end
