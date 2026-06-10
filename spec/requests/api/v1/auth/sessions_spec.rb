# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let!(:user) { create(:user, email: 'reader@example.com', password: 'Password1!') }

  describe 'POST /api/v1/auth/login' do
    it 'accepts login when the browser Origin differs from the proxied base URL' do
      post '/api/v1/auth/login',
           params: { user: { email: 'reader@example.com', password: 'Password1!' } },
           headers: {
             'Origin' => 'http://localhost:5173',
             'HTTP_HOST' => 'app:3000'
           },
           as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns the user and a JWT for valid credentials' do
      post '/api/v1/auth/login',
           params: { user: { email: 'reader@example.com', password: 'Password1!' } },
           as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        'email' => 'reader@example.com',
        'username' => user.username,
        'preferred_language' => 'en'
      )
      expect(response.headers['Authorization']).to start_with('Bearer ')
    end

    it 'returns unauthorized for invalid credentials' do
      post '/api/v1/auth/login',
           params: { user: { email: 'reader@example.com', password: 'wrong' } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/auth/me' do
    it 'returns the current user when authenticated' do
      headers = auth_headers_for(user)

      get '/api/v1/auth/me', headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['email']).to eq('reader@example.com')
    end

    it 'returns unauthorized without a token' do
      get '/api/v1/auth/me', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    it 'logs out an authenticated user' do
      headers = auth_headers_for(user)

      delete '/api/v1/auth/logout', headers:, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end

    it 'logs out using only the JWT when no session cookie is present' do
      headers = auth_headers_for(user)

      reset!

      delete '/api/v1/auth/logout', headers:, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end

    it 'rejects logout without a token' do
      delete '/api/v1/auth/logout', as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'revokes the JWT so it cannot be reused' do
      headers = auth_headers_for(user)

      delete '/api/v1/auth/logout', headers:, as: :json
      expect(response).to have_http_status(:ok)

      reset!

      get '/api/v1/auth/me', headers:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
