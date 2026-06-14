# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::FrequencyTables', type: :request do
  describe 'GET /api/v1/frequency_tables' do
    it 'returns frequency tables ordered by name' do
      create(:frequency_table, name: 'wikipedia')
      create(:frequency_table, name: 'jpdb')

      get '/api/v1/frequency_tables', as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |item| item['name'] }).to eq(%w[jpdb wikipedia])
    end
  end
end
