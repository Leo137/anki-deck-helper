# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordSet, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:words) }
  end

  describe '.ransackable_attributes' do
    it 'allows searching by name' do
      expect(described_class.ransackable_attributes).to include('name')
    end
  end
end
