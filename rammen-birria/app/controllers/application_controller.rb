class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session

  attr_reader :current_user

  private

  def authenticate_access!
    token = bearer_token
    return render(json: { error: "No autorizado" }, status: :unauthorized) if token.blank?

    payload = JsonWebToken.decode(token)
    return render(json: { error: "Token inválido o expirado" }, status: :unauthorized) if payload.blank?

    user = User.find_by(id: payload[:sub], jti: payload[:jti])
    return render(json: { error: "No autorizado" }, status: :unauthorized) if user.nil?
    return render(json: { error: "No autorizado" }, status: :unauthorized) if payload[:token_version].to_i != user.token_version.to_i

    @current_user = user
  end

  def bearer_token
    auth = request.headers["Authorization"].to_s
    auth.start_with?("Bearer ") ? auth.split(" ", 2).last : nil
  end
end
