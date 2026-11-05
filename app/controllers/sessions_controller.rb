class SessionsController < ApplicationController
  def new
    # Renderiza la vista de inicio de sesión
  end

  def create
    user = User.find_by(email: params[:email])

    # Verificación segura que evita que la aplicación se caiga si hay un hash inválido o texto plano
    authenticated = begin
      user && user.authenticate(params[:password])
    rescue BCrypt::Errors::InvalidHash
      user && user.password_hash == params[:password]
    end

    if authenticated
      session[:user_id] = user.id
      redirect_to root_path, notice: "¡Bienvenido de vuelta!"
    else
      flash.now[:alert] = "Correo o contraseña inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Has cerrado sesión correctamente."
  end
end