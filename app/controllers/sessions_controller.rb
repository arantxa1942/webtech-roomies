class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Signed in successfully."
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out successfully."
  end
end
