# frozen_string_literal: true

module Api
  module V1
    class SearchController < BaseController
      WORDS_PER_PAGE = 8
      WORD_SETS_PER_PAGE = 5

      def index
        @query = params[:q].to_s.strip

        if @query.blank?
          @words = Word.none.page(1)
          @word_sets = WordSet.none.page(1)
          return
        end

        @words = search_words
        @word_sets = search_word_sets
      end

      private

      def search_words
        ransack_ids = Word.ransack(content_or_kana_cont: @query).result.pluck(:id)
        reading_ids = Word.joins(dictionary_entry: :readings)
                          .where('dictionary_readings.text ILIKE ?', like_query)
                          .pluck(:id)

        Word.includes(dictionary_entry: :readings)
            .where(id: (ransack_ids + reading_ids).uniq)
            .order(:content)
            .page(params[:page])
            .per(per_page(WORDS_PER_PAGE))
      end

      def search_word_sets
        WordSet.ransack(name_cont: @query)
               .result
               .order(:name)
               .page(params[:page])
               .per(per_page(WORD_SETS_PER_PAGE))
      end

      def like_query
        "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      end

      def per_page(default)
        params.fetch(:per_page, default).to_i.clamp(1, 50)
      end
    end
  end
end
