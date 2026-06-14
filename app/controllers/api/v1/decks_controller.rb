# frozen_string_literal: true

module Api
  module V1
    class DecksController < BaseController
      include JwtAuthenticatable

      before_action :set_deck, only: %i[show destroy]

      def index
        @decks = current_user.decks
                             .left_joins(:cards)
                             .group(:id)
                             .select('decks.*, COUNT(deck_cards.id) AS cards_count')
                             .order(:name)
      end

      def show
        @cards_count = @deck.cards.count
        @study_summary = Deck::Study::DeckStats.new(deck: @deck, user: current_user).summary
      end

      def destroy
        Deck::Destroyer.new(deck: @deck).call
        head :no_content
      end

      def create
        render_created_deck(Deck::Creator.new(user: current_user, **creation_params).call)
      rescue Deck::Creator::Error => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def set_deck
        @deck = current_user.decks.find(params[:id])
      end

      def deck_params
        params.require(:deck).permit(:name, word_set_ids: [], frequency_table_ids: [])
      end

      def creation_params
        deck_params.to_h.symbolize_keys.slice(:name, :word_set_ids, :frequency_table_ids)
      end

      def render_created_deck(deck)
        @deck = deck
        @cards_count = 0
        @study_summary = Deck::Study::DeckStats.new(deck:, user: current_user).summary
        render :show, status: :accepted
      end
    end
  end
end
