class AuthController < ApplicationController
  include ActionController::Cookies

  def register
    user = User.new(user_params)
    if user.save
      render json: { message: "registered" }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      access  = JsonWebToken.encode({ sub: user.id, jti: user.jti, token_version: user.token_version })
      refresh = JsonWebToken.encode({ sub: user.id, jti: user.jti, token_version: user.token_version, type: "refresh" }, ttl: JsonWebToken::REFRESH_TTL)
      set_refresh_cookie(refresh)
      render json: { access_token: access }, status: :ok
    else
      render json: { error: "Email o contraseña incorrectos." }, status: :unauthorized
    end
  end

  def refresh
    token = cookies.signed[:refresh_token]
    payload = JsonWebToken.decode(token)
    return render json: { error: "invalid_refresh" }, status: :unauthorized unless payload&.dig("type") == "refresh"

    user = User.find_by(id: payload["sub"], jti: payload["jti"])
    return render json: { error: "invalid_refresh" }, status: :unauthorized unless user

    return render json: { error: "invalid_refresh" }, status: :unauthorized unless payload["token_version"].to_i == user.token_version.to_i

    access  = JsonWebToken.encode({ sub: user.id, jti: user.jti, token_version: user.token_version })
    refresh = JsonWebToken.encode({ sub: user.id, jti: user.jti, token_version: user.token_version, type: "refresh" }, ttl: JsonWebToken::REFRESH_TTL)
    set_refresh_cookie(refresh)
    render json: { access_token: access }, status: :ok
  end

  def logout
    current_user&.update!(jti: SecureRandom.uuid)
    cookies.delete(:refresh_token, domain: cookie_domain, same_site: :none, secure: Rails.env.production?)
    render json: { message: "Logged out" }, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def set_refresh_cookie(token)
    dev = Rails.env.development?
    cookies.signed[:refresh_token] = {
      value: token,
      httponly: true,
      same_site: dev ? :lax : :none,
      secure:    dev ? false : true,
      domain:    dev ? nil : cookie_domain.presence, # evita domain="" en dev
      expires:   JsonWebToken::REFRESH_TTL.seconds.from_now
    }
  end

  def cookie_domain
    ENV["COOKIE_DOMAIN"] # en dev la dejamos nil
  end



  def cookie_domain
    return nil if Rails.env.development?
    ENV["COOKIE_DOMAIN"]
  end


  def current_user
    @current_user
  end
end