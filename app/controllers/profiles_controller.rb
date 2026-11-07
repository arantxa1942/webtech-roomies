class ProfilesController < ApplicationController
  before_action :authorize_profile
  def edit
  end

  def update
    if current_user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = "Could not update your profile."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:full_name, :bio, :contact_details)
  end
  def authorize_profile
    authorize current_user
  end
end