# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Study::Maturity do
  describe '.factor_for' do
    it 'increases by 0.3 for each correct response up to 5.0' do
      responses = [
        build(:deck_card_study_response, correct: true, created_at: 1.minute.ago),
        build(:deck_card_study_response, correct: true, created_at: Time.current)
      ]

      expect(described_class.factor_for(responses)).to eq(0.6)
    end

    it 'halves the factor for an incorrect response' do
      responses = [
        build(:deck_card_study_response, correct: true, created_at: 1.minute.ago),
        build(:deck_card_study_response, correct: true, created_at: 30.seconds.ago),
        build(:deck_card_study_response, correct: false, created_at: Time.current)
      ]

      expect(described_class.factor_for(responses)).to eq(0.3)
    end

    it 'caps the factor at 5.0' do
      responses = Array.new(20) do |index|
        build(:deck_card_study_response, correct: true, created_at: index.seconds.ago)
      end

      expect(described_class.factor_for(responses)).to eq(5.0)
    end
  end

  describe '.stage_for' do
    it 'classifies young cards as 0.0 through 1.0' do
      expect(described_class.stage_for(0.0)).to eq(:young)
      expect(described_class.stage_for(1.0)).to eq(:young)
    end

    it 'classifies learning cards above 1.0 through 2.0' do
      expect(described_class.stage_for(1.2)).to eq(:learning)
      expect(described_class.stage_for(2.0)).to eq(:learning)
    end

    it 'classifies mature cards above 2.0 through 5.0' do
      expect(described_class.stage_for(2.1)).to eq(:mature)
      expect(described_class.stage_for(5.0)).to eq(:mature)
    end
  end
end
