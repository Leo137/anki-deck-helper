# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Search', type: :request do
  describe 'GET /api/v1/search' do
    it 'returns empty results when the query is blank' do
      create(:word)
      create(:word_set)

      get '/api/v1/search', params: { q: '   ' }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['query']).to eq('')
      expect(body['words']).to eq([])
      expect(body['word_sets']).to eq([])
      expect(body['pagination']['words']['total_count']).to eq(0)
      expect(body['pagination']['word_sets']['total_count']).to eq(0)
    end

    it 'searches words by content' do
      match = create(:word, content: '食べる')
      create(:word, content: '飲む')

      get '/api/v1/search', params: { q: '食べ' }, as: :json

      body = JSON.parse(response.body)
      expect(body['words'].map { |word| word['id'] }).to eq([match.id])
      expect(body['words'].first).to include('content' => '食べる', 'reading' => nil)
    end

    it 'searches words by kana' do
      match = create(:word, content: '食べる', kana: 'たべる')
      create(:word, content: '飲む', kana: 'のむ')

      get '/api/v1/search', params: { q: 'たべ' }, as: :json

      body = JSON.parse(response.body)
      expect(body['words'].map { |word| word['id'] }).to eq([match.id])
    end

    it 'searches words by dictionary reading text' do
      word = create(:word, content: '見る')
      entry = create(:dictionary_entry, text: '見る別')
      create(:dictionary_reading, dictionary_entry: entry, text: '見る', is_kana: false)
      create(:word, content: ' unrelated')

      get '/api/v1/search', params: { q: '見る' }, as: :json

      body = JSON.parse(response.body)
      expect(body['words'].map { |word| word['id'] }).to include(word.id)
    end

    it 'searches word sets by name' do
      match = create(:word_set, name: 'core vocabulary')
      create(:word_set, name: 'anime')

      get '/api/v1/search', params: { q: 'core' }, as: :json

      body = JSON.parse(response.body)
      expect(body['word_sets']).to eq([
                                       {
                                         'id' => match.id,
                                         'name' => 'core vocabulary',
                                         'words_count' => 0
                                       }
                                     ])
    end

    it 'paginates words and word sets independently' do
      9.times { |index| create(:word, content: "word#{index}") }
      6.times { |index| create(:word_set, name: "set#{index}") }

      get '/api/v1/search', params: { q: 'word', page: 2, per_page: 8 }, as: :json

      body = JSON.parse(response.body)
      expect(body['pagination']['words']).to include(
        'current_page' => 2,
        'per_page' => 8,
        'total_count' => 9,
        'total_pages' => 2
      )
      expect(body['pagination']['word_sets']['total_count']).to eq(0)
    end

    it 'clamps per_page to a maximum of 50' do
      create(:word, content: 'searchable')

      get '/api/v1/search', params: { q: 'search', per_page: 100 }, as: :json

      body = JSON.parse(response.body)
      expect(body['pagination']['words']['per_page']).to eq(50)
      expect(body['pagination']['word_sets']['per_page']).to eq(50)
    end

    it 'escapes SQL wildcard characters in reading search' do
      word = create(:word, content: '100%')
      entry = create(:dictionary_entry, text: 'percent')
      create(:dictionary_reading, dictionary_entry: entry, text: '100%', is_kana: false)
      create(:word, content: '1000')

      get '/api/v1/search', params: { q: '100%' }, as: :json

      body = JSON.parse(response.body)
      expect(body['words'].map { |item| item['id'] }).to contain_exactly(word.id)
    end
  end
end
