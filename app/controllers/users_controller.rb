class UsersController < ApplicationController
  include Collectr::FlickrStreamsControllerHelper
  NUM_OF_PIX_TO_SHOW = 12

  before_action :authenticate, except: [:show, :flickr_stream]

  def show
    flickr_stream
  end

  def flickr_stream
    redirect_to find_flickr_streams_path(user_id: params[:id], type: params[:type]  || FlickrStream::DEFAULT_TYPE)
  end

  def contacts
    render_json data_for_streams(Collectr::ContactsImporter.new(@current_collector).contact_streams)
  end

  def index
  end

  # post users/search
  def search
    keyword = params[:keyword]
    user = nil
    
    # Try different search methods with error handling
    begin
      # Try to find user by username
      user = flickr.people.find_by_username(keyword)
    rescue => e
      Rails.logger.debug("Failed to find user by username: #{e.message}")
    end
    
    begin
      # Try to find user by email if username search failed
      user ||= flickr.people.find_by_email(keyword)
    rescue => e
      Rails.logger.debug("Failed to find user by email: #{e.message}")
    end
    
    begin
      # If all else fails, try direct user_id lookup
      # Use find method which is the equivalent of getInfo in flickr-objects
      user ||= flickr.people.find(keyword)
    rescue => e
      Rails.logger.debug("Failed to find user by ID: #{e.message}")
    end

    respond_to do |format|
      format.html do
        if(user)
          redirect_to(user_path(id: user.id))
        else
          # Use redirect_back instead of redirect_to(:back)
          redirect_back(fallback_location: root_path, notice: "User not found")
        end
      end
      format.json do
        if user.present?
          render_json data_for_streams(streams_for_user(user.id))
        else
          render_json []
        end
      end
    end
  end

  private
  def streams_for_user user_id
    begin
      [ 
        FlickrStream.find_or_create(user_id: user_id, collector: current_collector, type: FaveStream.to_s),
        FlickrStream.find_or_create(user_id: user_id, collector: current_collector, type: UploadStream.to_s)
      ]
    rescue => e
      Rails.logger.error("Error creating streams for user #{user_id}: #{e.message}")
      []
    end
  end

end
