# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::Preferences', type: :request do
  let!(:user) { create(:user, preferred_language: 'en') }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/v1/users/preferences' do
    it 'returns the user preferences' do
      get '/api/v1/users/preferences', headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['preferred_language']).to eq('en')
      expect(body['available_languages']).to eq(User::PREFERRED_LANGUAGES)
    end

    it 'returns unauthorized without a token' do
      get '/api/v1/users/preferences', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/users/preferences' do
    it 'updates the preferred language' do
      patch '/api/v1/users/preferences',
            params: { preferences: { preferred_language: 'ja' } },
            headers:,
            as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['preferred_language']).to eq('ja')
      expect(user.reload.preferred_language).to eq('ja')
    end

    it 'returns validation errors for an invalid language' do
      patch '/api/v1/users/preferences',
            params: { preferences: { preferred_language: 'invalid' } },
            headers:,
            as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Preferred language is not included in the list')
    end
  end
end
