# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Decks', type: :request do
  include ActiveJob::TestHelper

  let!(:user) { create(:user, preferred_language: 'en') }
  let!(:other_user) { create(:user) }
  let!(:dictionary) { create(:dictionary, :english_jmdict) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/v1/decks' do
    it 'returns the current user decks ordered by name with cards_count and status' do
      create(:deck, user:, name: 'zebra', status: :ready)
      first = create(:deck, user:, name: 'apple', status: :ready, generation_progress: 100)
      create(:deck_card, :complete, deck: first, position: 1)
      create(:deck, user: other_user, name: 'other')

      get '/api/v1/decks', headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |item| item['name'] }).to eq(%w[apple zebra])
      expect(body.first).to include(
        'id' => first.id,
        'name' => 'apple',
        'cards_count' => 1,
        'status' => 'ready',
        'error_message' => nil,
        'generation_progress' => 100
      )
      expect(body.second['cards_count']).to eq(0)
    end

    it 'returns unauthorized without a token' do
      get '/api/v1/decks', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/decks/:id' do
    it 'returns deck details for the current user' do
      deck = create(:deck, user:, name: 'Core', status: :processing)

      get "/api/v1/decks/#{deck.id}", headers:, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'id' => deck.id,
        'name' => 'Core',
        'status' => 'processing',
        'cards_count' => 0,
        'generation_progress' => 0,
        'study_summary' => {
          'not_reviewed_count' => 0,
          'young_count' => 0,
          'learning_count' => 0,
          'mature_count' => 0
        }
      )
    end

    it 'returns combined study summary for reviewed cards' do
      deck = create(:deck, user:, name: 'Core', status: :ready)
      reviewed = create(:deck_card, :complete, deck:, position: 1)
      create(:deck_card, :complete, deck:, position: 2)
      create(:deck_card_study_response, user:, deck_card: reviewed, correct: true)

      get "/api/v1/decks/#{deck.id}", headers:, as: :json

      body = JSON.parse(response.body)
      expect(body['study_summary']).to include(
        'not_reviewed_count' => 1,
        'young_count' => 1,
        'learning_count' => 0,
        'mature_count' => 0
      )
    end
  end

  describe 'POST /api/v1/decks' do
    let!(:word_set) { create(:word_set) }
    let!(:frequency_table) { create(:frequency_table) }

    it 'accepts a deck creation request and enqueues background generation' do
      expect do
        post '/api/v1/decks',
             params: {
               deck: {
                 name: 'SRS Core',
                 word_set_ids: [word_set.id],
                 frequency_table_ids: [frequency_table.id]
               }
             },
             headers:,
             as: :json
      end.to have_enqueued_job(DeckCreationJob)

      expect(response).to have_http_status(:accepted)
      body = JSON.parse(response.body)
      expect(body).to include(
        'name' => 'SRS Core',
        'status' => 'pending',
        'cards_count' => 0,
        'generation_progress' => 0
      )
    end

    it 'returns validation errors for invalid input' do
      post '/api/v1/decks',
           params: { deck: { name: '', word_set_ids: [], frequency_table_ids: [] } },
           headers:,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Name is required')
    end

    it 'generates cards when the background job runs' do
      word = create(:word)
      word_set.words << word
      create(:word_frequency, word:, frequency_table:, frequency: 5)

      perform_enqueued_jobs do
        post '/api/v1/decks',
             params: {
               deck: {
                 name: 'Generated',
                 word_set_ids: [word_set.id],
                 frequency_table_ids: [frequency_table.id]
               }
             },
             headers:,
             as: :json
      end

      deck = user.decks.find_by!(name: 'Generated')
      expect(deck).to be_ready
      expect(deck.cards.count).to eq(1)
      expect(deck.cards.first.front_field.html_content).to start_with('<h1>')
    end
  end

  describe 'DELETE /api/v1/decks/:id' do
    it 'deletes a ready deck and its cards' do
      deck = create(:deck, user:, name: 'Remove me', status: :ready)
      create(:deck_card, :complete, deck:, position: 1)

      expect do
        delete "/api/v1/decks/#{deck.id}", headers:, as: :json
      end.to change(Deck, :count).by(-1)
                                 .and change(Deck::Card, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(Deck.find_by(id: deck.id)).to be_nil
    end

    it 'deletes a pending deck' do
      deck = create(:deck, user:, name: 'Queued', status: :pending)

      expect do
        delete "/api/v1/decks/#{deck.id}", headers:, as: :json
      end.to change(Deck, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns not found for another user deck' do
      deck = create(:deck, user: other_user, name: 'Private')

      delete "/api/v1/decks/#{deck.id}", headers:, as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq('error' => 'Not found')
    end

    it 'returns unauthorized without a token' do
      deck = create(:deck, user:, name: 'Protected')

      delete "/api/v1/decks/#{deck.id}", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/decks/:id/anki_export' do
    it 'downloads an Anki import file for a deck with cards' do
      deck = create(:deck, user:, name: 'Core Vocab', status: :ready)
      card = create(:deck_card, :complete, deck:, position: 1)
      front = card.front_field.html_content
      back = card.back_field.html_content

      get "/api/v1/decks/#{deck.id}/anki_export", headers:, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/plain')
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition']).to include('Core Vocab.txt')
      body = response.body.dup.force_encoding(Encoding::UTF_8)
      expect(body).to start_with('#front|back')
      expect(body).to include("#{front}|#{back}")
    end

    it 'returns unprocessable entity when the deck has no cards' do
      deck = create(:deck, user:, name: 'Empty', status: :ready)

      get "/api/v1/decks/#{deck.id}/anki_export", headers:, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to eq('errors' => ['Deck has no cards to export'])
    end

    it 'returns not found for another user deck' do
      deck = create(:deck, user: other_user, name: 'Private')
      create(:deck_card, :complete, deck:, position: 1)

      get "/api/v1/decks/#{deck.id}/anki_export", headers:, as: :json

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq('error' => 'Not found')
    end

    it 'returns unauthorized without a token' do
      deck = create(:deck, user:, name: 'Protected')
      create(:deck_card, :complete, deck:, position: 1)

      get "/api/v1/decks/#{deck.id}/anki_export", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
