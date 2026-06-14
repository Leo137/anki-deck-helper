# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Decks::Cards', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:deck) { create(:deck, user:, name: 'Core', status: :ready) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/v1/decks/:deck_id/cards' do
    it 'returns paginated cards for the deck ordered by position' do
      second = create(:deck_card, :complete, deck:, position: 2)
      first = create(:deck_card, :complete, deck:, position: 1)
      create(:deck_card, :complete, deck: create(:deck, user: other_user), position: 1)

      get "/api/v1/decks/#{deck.id}/cards", headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['cards'].map { |card| card['id'] }).to eq([first.id, second.id])
      expect(body['cards'].first).to include(
        'position' => 1,
        'front_preview' => 'ふもと'
      )
      expect(body['pagination']).to include(
        'page' => 1,
        'per_page' => 50,
        'total_count' => 2,
        'total_pages' => 1
      )
    end

    it 'returns not found for another user deck' do
      other_deck = create(:deck, user: other_user)

      get "/api/v1/decks/#{other_deck.id}/cards", headers:, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'returns unauthorized without a token' do
      get "/api/v1/decks/#{deck.id}/cards", as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'filters cards by front content' do
      matching = create(:deck_card, :complete, deck:, position: 1)
      matching.front_field.update!(html_content: '<h1>型</h1>')
      non_matching = create(:deck_card, :complete, deck:, position: 2)
      non_matching.front_field.update!(html_content: '<h1>要素</h1>')

      get "/api/v1/decks/#{deck.id}/cards", params: { q: '型' }, headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['cards'].map { |card| card['id'] }).to eq([matching.id])
      expect(body['cards'].first['front_preview']).to eq('型')
      expect(body['pagination']).to include('total_count' => 1)
    end

    it 'does not filter cards by back content alone' do
      card = create(:deck_card, :complete, deck:, position: 1)
      card.back_field.update!(html_content: '<div class="definition">* semiconductor</div>')

      get "/api/v1/decks/#{deck.id}/cards", params: { q: 'semiconductor' }, headers:, as: :json

      body = JSON.parse(response.body)
      expect(body['cards']).to eq([])
      expect(body['pagination']).to include('total_count' => 0)
    end
  end

  describe 'GET /api/v1/decks/:deck_id/cards/:id' do
    it 'returns card details with front and back fields' do
      card = create(:deck_card, :complete, deck:, position: 1)

      get "/api/v1/decks/#{deck.id}/cards/#{card.id}", headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        'id' => card.id,
        'position' => 1,
        'previous_card_id' => nil,
        'next_card_id' => nil,
        'deck' => { 'id' => deck.id, 'name' => 'Core' }
      )
      expect(body['fields'].map { |field| field['side'] }).to eq(%w[front back])
      expect(body['fields'].first['html_content']).to start_with('<h1>')
      expect(body['study_stats']).to include(
        'know_count' => 0,
        'dont_know_count' => 0,
        'total_responses' => 0,
        'accuracy_rate' => nil,
        'last_responded_at' => nil,
        'last_correct' => nil
      )
    end

    it 'includes study stats when responses exist' do
      card = create(:deck_card, :complete, deck:, position: 1)
      create(:deck_card_study_response, user:, deck_card: card, correct: true)
      create(:deck_card_study_response, user:, deck_card: card, correct: false)

      get "/api/v1/decks/#{deck.id}/cards/#{card.id}", headers:, as: :json

      body = JSON.parse(response.body)
      expect(body['study_stats']).to include(
        'know_count' => 1,
        'dont_know_count' => 1,
        'total_responses' => 2,
        'accuracy_rate' => 0.5,
        'last_correct' => false
      )
    end

    it 'returns neighboring card ids for navigation' do
      first = create(:deck_card, :complete, deck:, position: 1)
      middle = create(:deck_card, :complete, deck:, position: 2)
      last = create(:deck_card, :complete, deck:, position: 3)

      get "/api/v1/decks/#{deck.id}/cards/#{middle.id}", headers:, as: :json

      body = JSON.parse(response.body)
      expect(body).to include(
        'previous_card_id' => first.id,
        'next_card_id' => last.id
      )
    end

    it 'returns not found when the card does not belong to the deck' do
      card = create(:deck_card, :complete, deck: create(:deck, user:), position: 1)
      other_deck = create(:deck, user:, name: 'Other')

      get "/api/v1/decks/#{other_deck.id}/cards/#{card.id}", headers:, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
