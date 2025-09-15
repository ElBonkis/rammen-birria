module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  def authenticate!
    header = request.headers["Authorization"]
    token = header.to_s.split(" ").last
    payload = JsonWebToken.decode(token)
    return render json: { error: "unauthorized" }, status: :unauthorized unless payload

    user = User.find_by(id: payload["sub"], jti: payload["jti"])
    return render json: { error: "unauthorized" }, status: :unauthorized unless user

    return render json: { error: "unauthorized" }, status: :unauthorized unless payload["token_version"].to_i == user.token_version.to_i

    @current_user = user
  end
end