# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Decks::Study', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:deck) { create(:deck, user:, name: 'Core', status: :ready) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/v1/decks/:deck_id/study/next' do
    it 'returns the next study card with front and back fields' do
      card = create(:deck_card, :complete, deck:, position: 1)

      get "/api/v1/decks/#{deck.id}/study/next", headers:, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        'id' => card.id,
        'position' => 1,
        'deck' => { 'id' => deck.id, 'name' => 'Core' }
      )
      expect(body['fields'].map { |field| field['side'] }).to eq(%w[front back])
    end

    it 'can exclude a card from selection' do
      first = create(:deck_card, :complete, deck:, position: 1)
      second = create(:deck_card, :complete, deck:, position: 2)

      allow_any_instance_of(Deck::Study::CardPicker).to receive(:rand).and_return(0.0)

      get "/api/v1/decks/#{deck.id}/study/next",
          params: { exclude_card_id: first.id },
          headers:,
          as: :json

      body = JSON.parse(response.body)
      expect(body['id']).to eq(second.id)
    end

    it 'returns unprocessable entity when the deck has no cards' do
      get "/api/v1/decks/#{deck.id}/study/next", headers:, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to eq('error' => 'No cards available')
    end

    it 'returns not found for another user deck' do
      other_deck = create(:deck, user: other_user)

      get "/api/v1/decks/#{other_deck.id}/study/next", headers:, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/decks/:deck_id/study/responses' do
    it 'records a study response and returns updated stats' do
      card = create(:deck_card, :complete, deck:, position: 1)

      post "/api/v1/decks/#{deck.id}/study/responses",
           params: { response: { card_id: card.id, correct: false } },
           headers:,
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body).to include(
        'know_count' => 0,
        'dont_know_count' => 1,
        'total_responses' => 1,
        'accuracy_rate' => 0.0,
        'last_correct' => false
      )
      expect(body['last_responded_at']).to be_present
      expect(Deck::Card::StudyResponse.count).to eq(1)
    end

    it 'returns not found when the card does not belong to the deck' do
      card = create(:deck_card, :complete, deck: create(:deck, user:), position: 1)
      other_deck = create(:deck, user:, name: 'Other')

      post "/api/v1/decks/#{other_deck.id}/study/responses",
           params: { response: { card_id: card.id, correct: true } },
           headers:,
           as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
