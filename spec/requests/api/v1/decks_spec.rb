# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Decks', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/v1/decks' do
    it 'returns the current user decks ordered by name with words_count' do
      create(:deck, user:, name: 'zebra')
      first = create(:deck, user:, name: 'apple')
      word = create(:word)
      first.deck_words.create!(word:, position: 1)
      create(:deck, user: other_user, name: 'other')

      get '/api/v1/decks', headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |item| item['name'] }).to eq(%w[apple zebra])
      expect(body.first).to include('id' => first.id, 'name' => 'apple', 'words_count' => 1)
      expect(body.second['words_count']).to eq(0)
    end

    it 'returns unauthorized without a token' do
      get '/api/v1/decks', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
