# frozen_string_literal: true

module Api
  module V1
    module Paginatable
      extend ActiveSupport::Concern

      DEFAULT_PER_PAGE = 50
      MAX_PER_PAGE = 100

      private

      def paginate(scope)
        page = [params[:page].to_i, 1].max
        per_page = params.fetch(:per_page, DEFAULT_PER_PAGE).to_i.clamp(1, MAX_PER_PAGE)
        total_count = scope.count

        {
          records: scope.offset((page - 1) * per_page).limit(per_page),
          pagination: pagination_meta(page, per_page, total_count)
        }
      end

      def pagination_meta(page, per_page, total_count)
        {
          page:,
          per_page:,
          total_count:,
          total_pages: (total_count.to_f / per_page).ceil
        }
      end
    end
  end
end
