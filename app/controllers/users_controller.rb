class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_signed_in, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Roomies, #{@user.full_name}!"
    else
      flash.now[:alert] = "Could not create your account."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_signed_in
    redirect_to root_path, notice: "You are already signed in." if authenticated?
  end

  # role is never mass-assignable: every new account is a member.
  def user_params
    params.require(:user).permit(
      :full_name, :email_address, :password, :password_confirmation,
      :contact_details, :bio
    )
  end
end
