# frozen_string_literal: true

module Api
  module V1
    module WordSets
      class WordsController < BaseController
        def index
          @language = requested_language
          @word_set = WordSet.find(params[:word_set_id])
          scope = @word_set.words
                           .includes(:tags, word_frequencies: :frequency_table)
                           .order(:content)
          paginated = paginate(scope)
          @words = paginated[:records]
          Word.preload_dictionary_entries_for!(@words, language: @language)
          @pagination = paginated[:pagination]
        end

        private

        def requested_language
          (params[:language].presence || 'en').to_sym
        end
      end
    end
  end
end
