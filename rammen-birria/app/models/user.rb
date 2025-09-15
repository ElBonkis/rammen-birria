class User < ApplicationRecord
  has_secure_password
  before_create :set_jti
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  after_initialize { self.token_version ||= 1 }

  RESET_EXPIRY = 30.minutes

  def generate_password_reset!
    self.reset_password_token = loop do
      t = SecureRandom.urlsafe_base64(32)
      break t unless self.class.exists?(reset_password_token: t)
    end
    self.reset_password_sent_at = Time.current
    save!(validate: false)
  end

  def increment_token_version!
    increment!(:token_version)  # invalida todos los refresh/access previos
  end

  def clear_password_reset!
    update_columns(reset_password_token: nil, reset_password_sent_at: nil)
  end

  def password_reset_expired?
    reset_password_sent_at.blank? || reset_password_sent_at < RESET_EXPIRY.ago
  end

  private

  def set_jti
    self.jti = SecureRandom.uuid
  end
end
