class AuthenticationsController < ApplicationController

  #GET validate
  def validate
    auth = flickr.auth.getToken(frob: params[:frob])
    collector = ::Collector.find_or_create_by_auth(auth)
    session[:collector_id] = collector.id
    self.current_collector = collector
    redirect_to_stored
  end

end