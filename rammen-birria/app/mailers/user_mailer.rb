class UserMailer < ApplicationMailer
  default from: "no-reply@invensa.test"

  def password_reset(user, front_url:)
    @user  = user
    @url   = "#{front_url}/reset-password?token=#{CGI.escape(user.reset_password_token)}&email=#{CGI.escape(user.email)}"
    mail to: user.email, subject: "Recupera tu contraseña"
  end
end