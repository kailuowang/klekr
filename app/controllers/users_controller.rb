class UsersController < ApplicationController
  def show
    user_id = params[:id]
    @user = flickr.people.getInfo(user_id: user_id)
    stream = UploadStream.new(:user_id => user_id)

    @pictures = stream.get_pictures_from_flickr(4).map do |pic_info|
      Picture.create_from_pic_info pic_info
    end

    fave_stream = FaveStream.new(:user_id => user_id)
    @faves = fave_stream.get_pictures_from_flickr(4).map do |pic_info|
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

end
