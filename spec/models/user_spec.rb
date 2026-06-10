# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to validate_inclusion_of(:preferred_language).in_array(User::PREFERRED_LANGUAGES) }

    it 'requires a complex password on create' do
      user.password = 'short'
      user.password_confirmation = 'short'

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(
        'must be at least 8 characters and include one uppercase letter and one special character'
      )
    end

    it 'accepts a password with uppercase and special characters' do
      user.password = 'Secure1!'
      user.password_confirmation = 'Secure1!'

      expect(user).to be_valid
    end

    it 'rejects passwords without an uppercase letter' do
      user.password = 'password1!'
      user.password_confirmation = 'password1!'

      expect(user).not_to be_valid
    end

    it 'rejects passwords without a special character' do
      user.password = 'Password1'
      user.password_confirmation = 'Password1'

      expect(user).not_to be_valid
    end
  end

  describe '.authenticate_by_email' do
    it 'returns the user when the password is correct' do
      user = create(:user, email: 'reader@example.com', password: 'Password1!')

      expect(described_class.authenticate_by_email('reader@example.com', 'Password1!')).to eq(user)
    end

    it 'returns nil when the password is incorrect' do
      create(:user, email: 'reader@example.com', password: 'Password1!')

      expect(described_class.authenticate_by_email('reader@example.com', 'wrong')).to be_nil
    end
  end
end
