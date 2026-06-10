# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordTag, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:word) }
    it { is_expected.to belong_to(:tag) }
  end
end
