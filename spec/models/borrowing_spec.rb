require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    context 'user cannot borrow same book multiple times' do
      let(:user) { create(:user) }
      let(:book) { create(:book) }

      before { create(:borrowing, user: user, book: book) }

      it 'prevents borrowing the same book twice' do
        duplicate_borrowing = build(:borrowing, user: user, book: book)
        expect(duplicate_borrowing).not_to be_valid
        expect(duplicate_borrowing.errors[:base]).to include('You have already borrowed this book')
      end
    end

    context 'book must be available' do
      let(:unavailable_book) { create(:book, :unavailable) }

      it 'prevents borrowing unavailable books' do
        borrowing = build(:borrowing, book: unavailable_book)
        expect(borrowing).not_to be_valid
        expect(borrowing.errors[:book]).to include('is not available')
      end
    end
  end

  describe 'validations for dates' do
    it 'requires borrowed_at or sets it automatically' do
      borrowing = build(:borrowing, borrowed_at: nil, due_date: nil)
      borrowing.valid?
      expect(borrowing.borrowed_at).to be_present
    end

    it 'requires due_date or sets it automatically' do
      borrowing = build(:borrowing, borrowed_at: nil, due_date: nil)
      borrowing.valid?
      expect(borrowing.due_date).to be_present
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets borrowed_at to current time if not set' do
        borrowing = build(:borrowing, borrowed_at: nil, due_date: nil)
        borrowing.valid?
        expect(borrowing.borrowed_at).to be_present
        expect(borrowing.borrowed_at).to be_within(1.second).of(Time.current)
      end

      it 'sets due_date to 2 weeks from borrowed_at if not set' do
        borrowing = build(:borrowing, borrowed_at: nil, due_date: nil)
        borrowing.valid?
        expect(borrowing.due_date).to be_within(1.second).of(borrowing.borrowed_at + 2.weeks)
      end
    end

    describe 'after_create' do
      it 'decreases book available_copies' do
        book = create(:book, available_copies: 5)
        expect {
          create(:borrowing, book: book)
        }.to change { book.reload.available_copies }.by(-1)
      end
    end

    describe 'after_update' do
      it 'increases book available_copies when marked as returned' do
        book = create(:book, available_copies: 3)
        borrowing = create(:borrowing, book: book)

        expect {
          borrowing.mark_as_returned!
        }.to change { book.reload.available_copies }.by(1)
      end
    end
  end

  describe 'scopes' do
    let!(:active_borrowing) { create(:borrowing) }
    let!(:returned_borrowing) { create(:borrowing, :returned) }
    let!(:overdue_borrowing) { create(:borrowing, :overdue) }
    let!(:due_today_borrowing) { create(:borrowing, :due_today) }

    describe '.active' do
      it 'returns only non-returned borrowings' do
        expect(Borrowing.active).to include(active_borrowing, overdue_borrowing, due_today_borrowing)
        expect(Borrowing.active).not_to include(returned_borrowing)
      end
    end

    describe '.returned' do
      it 'returns only returned borrowings' do
        expect(Borrowing.returned).to include(returned_borrowing)
        expect(Borrowing.returned).not_to include(active_borrowing, overdue_borrowing)
      end
    end

    describe '.overdue' do
      it 'returns only overdue borrowings' do
        expect(Borrowing.overdue).to include(overdue_borrowing)
        expect(Borrowing.overdue).not_to include(active_borrowing, returned_borrowing)
      end
    end

    describe '.due_today' do
      it 'returns borrowings due today' do
        expect(Borrowing.due_today).to include(due_today_borrowing)
        expect(Borrowing.due_today).not_to include(active_borrowing, overdue_borrowing)
      end
    end

    describe '.for_user' do
      let(:user) { create(:user) }
      let!(:user_borrowing) { create(:borrowing, user: user) }

      it 'returns borrowings for specific user' do
        expect(Borrowing.for_user(user.id)).to include(user_borrowing)
        expect(Borrowing.for_user(user.id)).not_to include(active_borrowing)
      end
    end
  end

  describe '#returned?' do
    it 'returns true when returned_at is present' do
      borrowing = create(:borrowing, :returned)
      expect(borrowing.returned?).to be true
    end

    it 'returns false when returned_at is nil' do
      borrowing = create(:borrowing)
      expect(borrowing.returned?).to be false
    end
  end

  describe '#overdue?' do
    it 'returns true when not returned and past due_date' do
      borrowing = create(:borrowing, :overdue)
      expect(borrowing.overdue?).to be true
    end

    it 'returns false when returned' do
      borrowing = create(:borrowing, :returned)
      expect(borrowing.overdue?).to be false
    end

    it 'returns false when not past due_date' do
      borrowing = create(:borrowing)
      expect(borrowing.overdue?).to be false
    end
  end

  describe '#mark_as_returned!' do
    let(:borrowing) { create(:borrowing) }

    it 'sets returned_at to current time' do
      expect {
        borrowing.mark_as_returned!
      }.to change { borrowing.returned_at }.from(nil)
    end
  end

  describe '#days_overdue' do
    it 'returns 0 when not overdue' do
      borrowing = create(:borrowing)
      expect(borrowing.days_overdue).to eq(0)
    end

    it 'returns number of days overdue' do
      borrowing = create(:borrowing, due_date: 5.days.ago, returned_at: nil)
      expect(borrowing.days_overdue).to eq(5)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:borrowing)).to be_valid
    end

    it 'creates a returned borrowing' do
      borrowing = create(:borrowing, :returned)
      expect(borrowing.returned?).to be true
    end

    it 'creates an overdue borrowing' do
      borrowing = create(:borrowing, :overdue)
      expect(borrowing.overdue?).to be true
    end

    it 'creates a borrowing due today' do
      borrowing = create(:borrowing, :due_today)
      expect(borrowing.due_date.to_date).to eq(Date.today)
    end
  end
end
