# frozen_string_literal: true

module AuthHelpers
  def auth_headers_for(user, password: 'Password1!')
    post '/api/v1/auth/login',
         params: { user: { email: user.email, password: } },
         as: :json

    token = response.headers['Authorization']
    { 'Authorization' => token }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
