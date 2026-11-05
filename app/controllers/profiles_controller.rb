class ProfilesController < ApplicationController
  def edit
  end

  def update
    if current_user.update(profile_params)
      redirect_to root_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    # Reemplazamos :name por :full_name (y mantenemos los demás campos del formulario)
    params.require(:user).permit(:full_name, :phone, :bio, :contact_details)
  end
end