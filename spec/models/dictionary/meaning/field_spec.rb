# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dictionary::Meaning::Field, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:dictionary_meaning).class_name('Dictionary::Meaning') }
  end
end
