# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = 'please-change-me@example.com'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth, :params_auth, :database_authenticatable]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = false
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.navigational_formats = []
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  config.jwt do |jwt|
    jwt.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') do
      if Rails.application.credentials.devise_jwt_secret_key.present?
        Rails.application.credentials.devise_jwt_secret_key
      elsif Rails.env.development? || Rails.env.test?
        'devise_jwt_secret_key_change_in_production'
      end
    end
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/login$}],
      ['POST', %r{^/api/v1/auth/signup$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/logout$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end
