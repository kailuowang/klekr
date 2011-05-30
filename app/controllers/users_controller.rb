class UsersController < ApplicationController
  NUM_OF_PIX_TO_SHOW = 12
  include Collectr::Flickr

  before_filter :authenticate

  def show
    user_id = params[:id]
    @user = flickr.people.getInfo(user_id: user_id)

    @fave_stream = FaveStream.of_user(@user.nsid).collected_by(current_collector).first
    @upload_stream = UploadStream.of_user(@user.nsid).collected_by(current_collector).first

    @pictures = upload_pictures(user_id)

    @faves = fave_pictures(user_id)

  end

  def subscribe
    stream = FlickrStream.build(user_id: params[:id], collector: current_collector, 'type' => params[:type])
    stream.save
    sync_new_stream(stream)
    respond_to do |format|
      format.html { redirect_to(user_path(id: params[:id]),
                                :notice => "Starting to collect #{stream.username}'s #{stream.type}" ) }
      format.xml  { head :ok }
    end
  end

  # put users/search
  def search
    keyword = params[:keyword]
    user = nil
    begin
      user = flickr.people.findByUsername(username: keyword)
    rescue FlickRaw::FailedResponse
    end
    begin
      user ||= flickr.people.findByEmail(find_email: keyword)
    rescue FlickRaw::FailedResponse
    end
    begin
      user ||= flickr.people.getInfo(user_id: keyword)
    rescue FlickRaw::FailedResponse
    end


    if(user)
      respond_to do |format|
        format.html { redirect_to(user_path(id: user.nsid)) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to(:back, :notice => "User not found") }
        format.xml  { head :not_found }
      end
    end
  end

  # GET /users
  # GET /users.xml
  def index
    respond_to do |format|
      format.html # index.html.haml
    end
  end


  private

  def upload_pictures(user_id)
    get_pictures_from( @upload_stream || UploadStream.new(user_id: user_id, collector: current_collector))
  end

  def fave_pictures(user_id)
    get_pictures_from(@fave_stream || FaveStream.new(user_id: user_id, collector: current_collector))
  end

  def get_pictures_from(stream)
    stream.get_pictures(NUM_OF_PIX_TO_SHOW)
  end

  def sync_new_stream(stream)
    stream.sync(nil, NUM_OF_PIX_TO_SHOW)
    stream.pictures.each(&:get_viewed)
  end

end
