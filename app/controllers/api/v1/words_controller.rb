# frozen_string_literal: true

module Api
  module V1
    class WordsController < BaseController
      def index
        @words = Word.includes(:tags, word_frequencies: :frequency_table).order(:content)
        @words = @words.joins(:word_sets).where(word_sets: { id: params[:word_set_id] }) if params[:word_set_id].present?
      end

      def show
        @word = Word.includes(:tags, :word_sets, { dictionary_entry: :readings },
                              word_frequencies: :frequency_table).find(params[:id])
        Word.preload_dictionary_entries_for!(@word)
        @dictionary_entries = @word.dictionary_entries
      end
    end
  end
end
