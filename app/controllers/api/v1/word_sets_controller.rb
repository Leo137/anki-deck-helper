# frozen_string_literal: true

module Api
  module V1
    class WordSetsController < BaseController
      def index
        @word_sets = WordSet.left_joins(:words)
                            .group(:id)
                            .select('word_sets.*, COUNT(words.id) AS words_count')
                            .order(:name)
      end

      def show
        @word_set = WordSet.find(params[:id])
        @words_count = @word_set.words.count
      end
    end
  end
end
