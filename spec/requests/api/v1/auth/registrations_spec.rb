# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/auth/signup' do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@example.com',
          username: 'newuser',
          password: 'Password1!',
          password_confirmation: 'Password1!'
        }
      }
    end

    it 'creates a user when the browser Origin differs from the proxied base URL' do
      post '/api/v1/auth/signup',
           params: valid_params,
           headers: {
             'Origin' => 'http://localhost:5173',
             'HTTP_HOST' => 'app:3000'
           },
           as: :json

      expect(response).to have_http_status(:created)
    end

    it 'creates a user and returns a JWT' do
      post '/api/v1/auth/signup', params: valid_params, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body).to include(
        'email' => 'newuser@example.com',
        'username' => 'newuser',
        'preferred_language' => 'en'
      )
      expect(response.headers['Authorization']).to start_with('Bearer ')
      expect(User.find_by(email: 'newuser@example.com')).to be_present
    end

    it 'returns validation errors for a weak password' do
      post '/api/v1/auth/signup',
           params: valid_params.deep_merge(user: { password: 'weak', password_confirmation: 'weak' }),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      errors = JSON.parse(response.body)['errors']
      expect(errors).to include(
        'Password must be at least 8 characters and include one uppercase letter and one special character'
      )
    end

    it 'returns validation errors for duplicate email' do
      create(:user, email: 'newuser@example.com')

      post '/api/v1/auth/signup', params: valid_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Email has already been taken')
    end
  end
end
