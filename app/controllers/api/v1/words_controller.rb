# frozen_string_literal: true

module Api
  module V1
    class WordsController < BaseController
      def index
        @words = Word.includes(:tags, word_frequencies: :frequency_table).order(:content)
        return unless params[:word_set_id].present?

        @words = @words.joins(:word_sets).where(word_sets: { id: params[:word_set_id] })
      end

      def show
        @language = requested_language
        @word = Word.includes(:tags, :word_sets, word_frequencies: :frequency_table).find(params[:id])
        Word.preload_dictionary_entries_for!(@word, language: @language)
        @dictionary_entries = @word.dictionary_entries(language: @language)
        @dictionary_ids = Word.dictionary_ids_for_language(@language)
      end

      private

      def requested_language
        (params[:language].presence || 'en').to_sym
      end
    end
  end
end
