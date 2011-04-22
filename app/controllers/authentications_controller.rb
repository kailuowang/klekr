class AuthenticationsController < ApplicationController

  #GET validate
  def validate
    auth = flickr.auth.getToken(frob: params[:frob])
    collector = ::Collector.find_or_create_by_auth(auth)
    session[:collector_id] = collector.id
    flash[:welcome_msg] =  "Welcome! #{current_collector.user_name}"
    redirect_to_stored
  end

end