# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Words', type: :request do
  describe 'GET /api/v1/words' do
    it 'returns all words ordered by content' do
      create(:word, content: 'zebra')
      create(:word, content: 'apple')

      get '/api/v1/words', as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |word| word['content'] }).to eq(%w[apple zebra])
      expect(body.first.keys).to include('id', 'content', 'reading', 'tags', 'frequencies')
    end

    it 'filters words by word_set_id' do
      word_set = create(:word_set)
      included = create(:word, word_sets: [word_set])
      create(:word)

      get '/api/v1/words', params: { word_set_id: word_set.id }, as: :json

      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body.first['id']).to eq(included.id)
    end

    it 'returns an empty array when word_set_id matches no words' do
      word_set = create(:word_set)
      create(:word)

      get '/api/v1/words', params: { word_set_id: word_set.id }, as: :json

      expect(JSON.parse(response.body)).to eq([])
    end

    it 'includes tags and frequency data' do
      table = create(:frequency_table, name: 'jpdb', max_frequency: 100)
      word = create(:word, :with_kana)
      tag = create(:tag, name: 'common')
      create(:word_tag, word:, tag:)
      create(:word_frequency, word:, frequency_table: table, frequency: 25)

      get '/api/v1/words', as: :json

      body = JSON.parse(response.body).find { |item| item['id'] == word.id }
      expect(body['reading']).to eq(word.kana)
      expect(body['tags']).to eq(['common'])
      expect(body['frequencies']).to eq([
                                          {
                                            'table' => 'jpdb',
                                            'frequency' => 25,
                                            'ratio' => 0.25
                                          }
                                        ])
    end
  end

  describe 'GET /api/v1/words/:id' do
    it 'returns the word with word sets and dictionary entries' do
      word = create(:word, content: '食べる')
      word_set = create(:word_set, name: 'core')
      word.word_sets << word_set
      entry = create(:dictionary_entry, text: word.content, jmdict_id: '100')
      meaning = create(:dictionary_meaning, dictionary_entry: entry)
      create(:dictionary_meaning_definition, dictionary_meaning: meaning, text: 'to eat')
      create(:dictionary_reading, :kana, dictionary_entry: entry, text: 'たべる')

      get "/api/v1/words/#{word.id}", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['content']).to eq('食べる')
      expect(body['word_sets']).to eq([{ 'id' => word_set.id, 'name' => 'core' }])
      expect(body['dictionary_entries'].first).to include(
        'text' => '食べる',
        'readings' => ['たべる'],
        'senses' => [{ 'tags' => [], 'definitions' => ['to eat'] }]
      )
    end

    it 'returns not found for a missing word' do
      get '/api/v1/words/0', as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not found' })
    end
  end
end
