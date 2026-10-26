class CurrentUsersController < ApplicationController
  def update
    user = User.find(params[:user_id])
    session[:user_id] = user.id

    redirect_back fallback_location: root_path, notice: "Acting as #{user.full_name}."
  end
end