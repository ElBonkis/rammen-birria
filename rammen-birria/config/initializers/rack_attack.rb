class Rack::Attack
  if !Rails.env.test?
    throttle("password_reset/ip", limit: 5, period: 10.minutes) do |req|
      req.ip if req.path == "/auth/password/forgot" && req.post?
    end

    throttle("password_reset/email", limit: 5, period: 10.minutes) do |req|
      if req.path == "/auth/password/forgot" && req.post?
        if req.content_type&.include?("application/json") && req.body && req.body.size < 10_000
          body = req.body.read
          req.body.rewind
          email = JSON.parse(body)["email"] rescue nil
          email&.downcase
        end
      end
    end

    self.throttled_response = lambda do |_env|
      [ 429, { "Content-Type" => "application/json" }, [ { error: "Demasiadas solicitudes. Intenta más tarde." }.to_json ] ]
    end
  end
end
