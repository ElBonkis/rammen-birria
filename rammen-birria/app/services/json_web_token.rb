class JsonWebToken
  ALGO = "HS256"
  ACCESS_TTL  = Integer(ENV.fetch("JWT_ACCESS_TTL", 900))
  REFRESH_TTL = Integer(ENV.fetch("JWT_REFRESH_TTL", 1_209_600))

  def self.encode(payload, ttl: ACCESS_TTL)
    payload = payload.dup
    payload[:exp] = Time.now.to_i + ttl
    JWT.encode(payload, secret, ALGO)
  end

  def self.decode(token)
    body, = JWT.decode(token, secret, true, { algorithm: ALGO })
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    Rails.application.credentials.dig(:jwt, :secret) || ENV.fetch("SECRET_KEY_BASE")
  end
end
