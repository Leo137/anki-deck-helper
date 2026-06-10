# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dictionary::Reading, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:dictionary_entry).class_name('Dictionary::Entry') }
  end
end
