class UsersController < ApplicationController
  def show
    user_id = params[:id]
    @user = flickr.people.getInfo(user_id: user_id)

    @fave_stream = FaveStream.find_by_user_id(@user.nsid)
    @upload_stream = UploadStream.find_by_user_id(@user.nsid)

    @pictures = (@upload_stream || UploadStream.new(:user_id => user_id)).
                  get_pictures_from_flickr(12).map do |pic_info|
      Picture.create_from_pic_info pic_info
    end

    @faves = (@fave_stream || FaveStream.new(:user_id => user_id)).
                  get_pictures_from_flickr(12).map do |pic_info|
      Picture.create_from_pic_info pic_info
    end

  end

  def subscribe
    respond_to do |format|
      stream = FlickrStream.build(user_id: params[:id], 'type' => params[:type])
      stream.save
      format.html { redirect_to(flickr_streams_path, :notice => "Successfully Subscribed to #{stream.username}'s #{stream.type}" ) }
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



end
