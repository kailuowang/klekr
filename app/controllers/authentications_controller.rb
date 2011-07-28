class AuthenticationsController < ApplicationController
  include Collectr::Flickr

  #GET validate
  def validate
    auth = flickr.auth.getToken(frob: params[:frob])
    collector = ::Collector.find_or_create_by_auth(auth)
    session[:collector_id] = collector.id
    self.current_collector = collector
    redirect_to_stored
  end

  #Get
  def show
    frob = flickr.auth.getFrob
    @auth_url = FlickRaw.auth_url(perms: 'write', frob: frob )
  end

end