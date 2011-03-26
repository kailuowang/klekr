class AuthenticationsController < ApplicationController
  #POST
  def login
    if(params[:password] == 'alf')
      session[:user] = 'alf'
      redirect_to_stored
    else
      redirect_to authentications_path, notice: 'Incorrect Password!'
    end
  end

  def show

  end


end