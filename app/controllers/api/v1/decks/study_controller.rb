# frozen_string_literal: true

module Api
  module V1
    module Decks
      class StudyController < BaseController
        include JwtAuthenticatable

        before_action :set_deck
        before_action :set_card, only: :create

        def next
          @card = Deck::Study::CardPicker.new(
            deck: @deck,
            user: current_user,
            exclude_card_id: params[:exclude_card_id]
          ).pick

          if @card.nil?
            render json: { error: 'No cards available' }, status: :unprocessable_entity
            return
          end

          @card = @deck.cards.includes(:fields).find(@card.id)
        end

        def create
          @study_response = Deck::Card::StudyResponse.create!(
            user: current_user,
            deck_card: @card,
            correct: ActiveModel::Type::Boolean.new.cast(study_response_params[:correct])
          )
          @study_stats = Deck::Card::StudyResponse.stats_for(user: current_user, card: @card)

          render :create, status: :created
        end

        private

        def set_deck
          @deck = current_user.decks.find(params[:deck_id])
        end

        def set_card
          @card = @deck.cards.find(study_response_params[:card_id])
        end

        def study_response_params
          params.require(:response).permit(:card_id, :correct)
        end
      end
    end
  end
end
