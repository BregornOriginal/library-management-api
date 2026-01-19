require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
    it { should have_many(:users).through(:borrowings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:isbn) }
    it { should validate_presence_of(:total_copies) }
    it { should validate_presence_of(:available_copies) }

    subject { create(:book) }
    it { should validate_uniqueness_of(:isbn).case_insensitive }

    it { should validate_numericality_of(:total_copies).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:available_copies).is_greater_than_or_equal_to(0) }

    it 'validates available_copies cannot exceed total_copies' do
      book = build(:book, total_copies: 5, available_copies: 10)
      expect(book).not_to be_valid
      expect(book.errors[:available_copies]).to include('cannot exceed total copies')
    end
  end

  describe 'scopes' do
    let!(:available_book) { create(:book, available_copies: 3) }
    let!(:unavailable_book) { create(:book, :unavailable) }
    let!(:ruby_book) { create(:book, title: 'Ruby Programming', author: 'John Doe', genre: 'Programming') }
    let!(:python_book) { create(:book, title: 'Python Basics', author: 'Jane Smith', genre: 'Programming') }

    describe '.available' do
      it 'returns only books with available copies' do
        expect(Book.available).to include(available_book, ruby_book, python_book)
        expect(Book.available).not_to include(unavailable_book)
      end
    end

    describe '.search_by_title' do
      it 'finds books by title (case insensitive)' do
        expect(Book.search_by_title('ruby')).to include(ruby_book)
        expect(Book.search_by_title('ruby')).not_to include(python_book)
      end
    end

    describe '.search_by_author' do
      it 'finds books by author (case insensitive)' do
        expect(Book.search_by_author('john')).to include(ruby_book)
        expect(Book.search_by_author('jane')).to include(python_book)
      end
    end

    describe '.search_by_genre' do
      it 'finds books by genre (case insensitive)' do
        expect(Book.search_by_genre('programming')).to include(ruby_book, python_book)
      end
    end
  end

  describe '#available?' do
    it 'returns true when copies are available' do
      book = create(:book, available_copies: 3)
      expect(book.available?).to be true
    end

    it 'returns false when no copies are available' do
      book = create(:book, :unavailable)
      expect(book.available?).to be false
    end
  end

  describe '#borrow!' do
    let(:book) { create(:book, available_copies: 3) }

    it 'decrements available_copies by 1' do
      expect { book.borrow! }.to change { book.reload.available_copies }.by(-1)
    end

    context 'when no copies are available' do
      let(:unavailable_book) { create(:book, :unavailable) }

      it 'raises an error' do
        expect { unavailable_book.borrow! }.to raise_error(StandardError, 'No copies available')
      end
    end
  end

  describe '#return!' do
    let(:book) { create(:book, total_copies: 5, available_copies: 3) }

    it 'increments available_copies by 1' do
      expect { book.return! }.to change { book.reload.available_copies }.by(1)
    end

    context 'when available_copies equals total_copies' do
      let(:full_book) { create(:book, total_copies: 5, available_copies: 5) }

      it 'does not increment available_copies' do
        expect { full_book.return! }.not_to change { full_book.reload.available_copies }
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:book)).to be_valid
    end

    it 'creates an unavailable book' do
      book = create(:book, :unavailable)
      expect(book.available?).to be false
    end

    it 'creates a limited availability book' do
      book = create(:book, :limited)
      expect(book.total_copies).to eq(2)
      expect(book.available_copies).to eq(1)
    end
  end
end
