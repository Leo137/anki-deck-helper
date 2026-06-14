# frozen_string_literal: true

module Api
  module V1
    module Decks
      class CardsController < BaseController
        include JwtAuthenticatable

        before_action :set_deck
        before_action :set_card, only: :show

        def index
          scope = @deck.cards.includes(:fields).order(:position)
          scope = scope.search_by_front_content(params[:q]) if params[:q].present?
          paginated = paginate(scope)
          @cards = paginated[:records]
          @pagination = paginated[:pagination]
        end

        def show
          @previous_card_id = neighbor_card_id(:desc, '<')
          @next_card_id = neighbor_card_id(:asc, '>')
          @study_stats = Deck::Card::StudyResponse.stats_for(user: current_user, card: @card)
        end

        private

        def neighbor_card_id(direction, operator)
          @deck.cards
               .where("position #{operator} ?", @card.position)
               .reorder(position: direction)
               .limit(1)
               .pick(:id)
        end

        def set_deck
          @deck = current_user.decks.find(params[:deck_id])
        end

        def set_card
          @card = @deck.cards.includes(:fields).find(params[:id])
        end
      end
    end
  end
end
