class UsersController < ApplicationController
  include Collectr::FlickrStreamsControllerHelper
  NUM_OF_PIX_TO_SHOW = 12

  before_filter :authenticate , except: [:show, :flickr_stream]

  def show
    type = params[:type] || FlickrStream::DEFAULT_TYPE
    redirect_to(action: :flickr_stream, type: type)
  end

  def flickr_stream
    stream = FlickrStream.find_or_create(user_id: params[:id], collector: collector_for_stream, type: params[:type])
    redirect_to(action: :flickr_stream, controller: :slideshow, id: stream.id)
  end


  def contacts
    render_json data_for_streams(Collectr::ContactsImporter.new(@current_collector).contact_streams)
  end

  def index
  end

  # post users/search
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
      format.json do
        render_json user.present? ? data_for_streams(streams_for_user(user.nsid)) : []
      end
    end
  end

  private
  def streams_for_user user_id
    [ FlickrStream.find_or_create(user_id: user_id, collector: current_collector, type: FaveStream.to_s),
      FlickrStream.find_or_create(user_id: user_id, collector: current_collector, type: UploadStream.to_s)]
  end

  def collector_for_stream
    current_collector || Collectr::Editor.new.ensure_editor_collector
  end
end
