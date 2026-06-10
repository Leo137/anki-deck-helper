# frozen_string_literal: true

require 'devise/orm/active_record'

class User < ApplicationRecord
  PREFERRED_LANGUAGES = %w[en fr de es pt ru ja].freeze
  PASSWORD_FORMAT = /\A(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}\z/

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { minimum: 2, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/ }
  validates :preferred_language, inclusion: { in: PREFERRED_LANGUAGES }
  validates :password, format: {
    with: PASSWORD_FORMAT,
    message: 'must be at least 8 characters and include one uppercase letter and one special character'
  }, if: :password_required?

  def self.authenticate_by_email(email, password)
    user = find_for_authentication(email: email.downcase)
    user if user&.valid_password?(password)
  end
end
