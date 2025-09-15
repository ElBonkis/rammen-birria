class PasswordResetsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    user&.generate_password_reset!
    head :ok
  end

  def update
    user = User.find_by(reset_password_token: params[:token])
    return render json: { error: "Token inválido" }, status: :unprocessable_entity if user.nil?
    return render json: { error: "Token expirado" }, status: :unprocessable_entity if user.password_reset_expired?

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      user.clear_password_reset!
      user.increment_token_version!
      render json: { message: "password_updated" }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
