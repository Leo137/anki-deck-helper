# frozen_string_literal: true

module Api
  module V1
    class FrequencyTablesController < BaseController
      def index
        @frequency_tables = FrequencyTable.order(:name)
      end
    end
  end
end
