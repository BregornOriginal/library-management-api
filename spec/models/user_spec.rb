require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }

    subject { create(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, librarian: 1) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes jwt_authenticatable' do
      expect(User.devise_modules).to include(:jwt_authenticatable)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'creates a librarian user' do
      librarian = create(:user, :librarian)
      expect(librarian.librarian?).to be true
    end

    it 'creates a member user by default' do
      member = create(:user)
      expect(member.member?).to be true
    end
  end
end
