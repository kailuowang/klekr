class AuthenticationsController < ApplicationController

  #GET validate
  def validate
    auth = flickr.auth.getToken(frob: params[:frob])
    collector = ::Collector.find_or_create_by_auth(auth)
    collector.update_attribute(:last_login, DateTime.now)
    session[:collector_id] = collector.id
    self.current_collector = collector
    redirect_to_stored
  end

  #Get
  def show
    @disable_navigation = true
    @redirected_to_login = redirected_for_login
    frob = flickr.auth.getFrob
    @auth_url = FlickRaw.auth_url(perms: 'write', frob: frob )
    @show_detail = params[:show_detail].present?
    current_collector
  end

  #delete
  def destroy
    @disable_navigation = true
    reset_session
    render 'bye'
  end

end