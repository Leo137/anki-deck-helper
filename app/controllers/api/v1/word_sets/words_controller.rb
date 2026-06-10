# frozen_string_literal: true

module Api
  module V1
    module WordSets
      class WordsController < BaseController
        def index
          @word_set = WordSet.find(params[:word_set_id])
          scope = @word_set.words
                           .includes(:tags, { dictionary_entry: :readings }, word_frequencies: :frequency_table)
                           .order(:content)
          paginated = paginate(scope)
          @words = paginated[:records]
          Word.preload_dictionary_entries_for!(@words)
          @pagination = paginated[:pagination]
        end
      end
    end
  end
end
