# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::WordSets::Words', type: :request do
  let(:word_set) { create(:word_set) }

  describe 'GET /api/v1/word_sets/:word_set_id/words' do
    it 'returns paginated words for the word set' do
      first = create(:word, content: 'apple', word_sets: [word_set])
      create(:word, content: 'zebra', word_sets: [word_set])

      get "/api/v1/word_sets/#{word_set.id}/words", params: { page: 1, per_page: 1 }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['words'].length).to eq(1)
      expect(body['words'].first['id']).to eq(first.id)
      expect(body['pagination']).to eq({
                                         'page' => 1,
                                         'per_page' => 1,
                                         'total_count' => 2,
                                         'total_pages' => 2
                                       })
    end

    it 'returns the second page of results' do
      create(:word, content: 'apple', word_sets: [word_set])
      second = create(:word, content: 'zebra', word_sets: [word_set])

      get "/api/v1/word_sets/#{word_set.id}/words", params: { page: 2, per_page: 1 }, as: :json

      body = JSON.parse(response.body)
      expect(body['words'].first['id']).to eq(second.id)
      expect(body['pagination']['page']).to eq(2)
    end

    it 'defaults to page 1 and 50 per page' do
      create_list(:word, 3, word_sets: [word_set])

      get "/api/v1/word_sets/#{word_set.id}/words", as: :json

      body = JSON.parse(response.body)
      expect(body['words'].length).to eq(3)
      expect(body['pagination']).to include('page' => 1, 'per_page' => 50, 'total_count' => 3, 'total_pages' => 1)
    end

    it 'clamps invalid pagination params' do
      create(:word, word_sets: [word_set])

      get "/api/v1/word_sets/#{word_set.id}/words", params: { page: 0, per_page: 500 }, as: :json

      body = JSON.parse(response.body)
      expect(body['pagination']).to include('page' => 1, 'per_page' => 100)
    end

    it 'returns an empty page for an empty word set' do
      get "/api/v1/word_sets/#{word_set.id}/words", as: :json

      body = JSON.parse(response.body)
      expect(body['words']).to eq([])
      expect(body['pagination']).to include('total_count' => 0, 'total_pages' => 0)
    end

    it 'returns not found for a missing word set' do
      get '/api/v1/word_sets/0/words', as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not found' })
    end
  end
end
