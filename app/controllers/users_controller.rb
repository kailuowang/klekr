class UsersController < ApplicationController
  NUM_OF_PIX_TO_SHOW = 12
  include Collectr::Flickr

  before_filter :authenticate

  def show
    redirect_to(action: :flickr_stream, type: FlickrStream::DEFAULT_TYPE)
  end

  def flickr_stream
    stream = FlickrStream.find_or_create(user_id: params[:id], collector: current_collector, type: params[:type])
    redirect_to(action: :show, controller: :flickr_streams, id: stream.id)
  end

  def index
  end

  # put users/search
  def search
    keyword = params[:keyword]
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

    respond_to do |format|
      format.html do
        if(user)
          redirect_to(user_path(id: user.nsid))
        else
          redirect_to(:back, :notice => "User not found")
        end
      end
    end
  end

end
