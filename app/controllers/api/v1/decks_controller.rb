# frozen_string_literal: true

module Api
  module V1
    class DecksController < BaseController
      include JwtAuthenticatable

      def index
        @decks = current_user.decks
                              .left_joins(:deck_words)
                              .group(:id)
                              .select('decks.*, COUNT(deck_words.id) AS words_count')
                              .order(:name)
      end
    end
  end
end
