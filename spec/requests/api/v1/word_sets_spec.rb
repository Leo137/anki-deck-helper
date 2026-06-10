# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::WordSets', type: :request do
  describe 'GET /api/v1/word_sets' do
    it 'returns all word sets ordered by name with words_count' do
      create(:word_set, name: 'zebra')
      first = create(:word_set, name: 'apple')
      word = create(:word)
      first.words << word

      get '/api/v1/word_sets', as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |item| item['name'] }).to eq(%w[apple zebra])
      expect(body.first).to include('id' => first.id, 'name' => 'apple', 'words_count' => 1)
      expect(body.second['words_count']).to eq(0)
    end
  end

  describe 'GET /api/v1/word_sets/:id' do
    it 'returns word set metadata without embedding words' do
      word_set = create(:word_set, name: 'core')
      word_set.words << create(:word)

      get "/api/v1/word_sets/#{word_set.id}", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        'id' => word_set.id,
        'name' => 'core',
        'words_count' => 1
      )
      expect(body.keys).to contain_exactly('id', 'name', 'created_at', 'updated_at', 'words_count')
      expect(body).not_to have_key('words')
    end

    it 'returns not found for a missing word set' do
      get '/api/v1/word_sets/0', as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not found' })
    end
  end
end
