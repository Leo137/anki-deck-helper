# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Paginatable

      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end
    end
  end
end
