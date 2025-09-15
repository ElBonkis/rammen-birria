module AuthHelpers
  def access_token_for(user)
    JsonWebToken.encode({
      sub: user.id,
      jti: user.jti,
      token_version: user.token_version
    })
  end

  def auth_headers_for(user)
    { "Authorization" => "Bearer #{access_token_for(user)}" }
  end

  def login!(user = FactoryBot.create(:user))
    [user, auth_headers_for(user)]
  end

  def json_headers
    { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
