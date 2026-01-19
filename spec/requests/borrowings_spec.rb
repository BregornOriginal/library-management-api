require 'rails_helper'

RSpec.describe 'Borrowings API', type: :request do
  # Sam Gamgee - loyal member who loves books about gardening
  let(:sam) { create(:user, :member, name: 'Samwise Gamgee', email: 'sam@shire.com') }

  # Aragorn - ranger and future king
  let(:aragorn) { create(:user, :member, name: 'Aragorn', email: 'strider@gondor.com') }

  # Elrond - wise librarian of Rivendell
  let(:librarian) { create(:user, :librarian, name: 'Elrond', email: 'elrond@rivendell.com') }

  let!(:lotr_book) do
    create(:book,
           title: 'The Lord of the Rings',
           author: 'J.R.R. Tolkien',
           genre: 'Fantasy',
           available_copies: 2)
  end

  let!(:silmarillion) do
    create(:book,
           title: 'The Silmarillion',
           author: 'J.R.R. Tolkien',
           genre: 'Fantasy',
           available_copies: 1)
  end

  let!(:unavailable_book) do
    create(:book,
           title: 'Red Book of Westmarch',
           author: 'Bilbo Baggins',
           genre: 'Adventure',
           available_copies: 0)
  end

  describe 'POST /borrowings' do
    let(:borrow_params) { { borrowing: { book_id: lotr_book.id } } }

    context 'as Sam (member)' do
      it 'allows Sam to borrow a book for his journey' do
        expect {
          post '/borrowings', params: borrow_params, headers: auth_headers(sam)
        }.to change(Borrowing, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['book']['title']).to eq('The Lord of the Rings')
        expect(json_response['user']['name']).to eq('Samwise Gamgee')

        # Check that available copies decreased
        expect(lotr_book.reload.available_copies).to eq(1)
      end

      it 'sets due date to 2 weeks from now' do
        post '/borrowings', params: borrow_params, headers: auth_headers(sam)

        borrowing = Borrowing.last
        expect(borrowing.due_date).to be_within(1.minute).of(2.weeks.from_now)
      end

      it 'prevents borrowing the same book twice (even Sam can only carry one Ring book)' do
        create(:borrowing, user: sam, book: lotr_book)

        post '/borrowings', params: borrow_params, headers: auth_headers(sam)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('You have already borrowed this book')
      end

      it 'prevents borrowing unavailable books' do
        unavailable_params = { borrowing: { book_id: unavailable_book.id } }
        post '/borrowings', params: unavailable_params, headers: auth_headers(sam)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('Book is not available')
      end
    end

    context 'without authentication' do
      it 'denies access (only members of the Fellowship can borrow)' do
        post '/borrowings', params: borrow_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /borrowings' do
    let!(:sam_borrowing) { create(:borrowing, user: sam, book: lotr_book) }
    let!(:aragorn_borrowing) { create(:borrowing, user: aragorn, book: silmarillion) }

    context 'as Sam (member)' do
      it 'shows only Sam\'s borrowed books' do
        get '/borrowings', headers: auth_headers(sam)

        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(1)
        expect(json_response.first['user']['name']).to eq('Samwise Gamgee')
      end

      it 'filters active borrowings' do
        another_book = create(:book, title: 'The Two Towers', author: 'J.R.R. Tolkien')
        create(:borrowing, :returned, user: sam, book: another_book)

        get '/borrowings', params: { status: 'active' }, headers: auth_headers(sam)

        expect(json_response.length).to eq(1)
        expect(json_response.first['returned_at']).to be_nil
      end
    end

    context 'as Elrond (librarian)' do
      it 'sees all borrowings in Middle-earth' do
        get '/borrowings', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(2)
      end

      it 'filters overdue borrowings' do
        overdue_book = create(:book, title: 'The Return of the King', author: 'J.R.R. Tolkien')
        create(:borrowing, :overdue, user: sam, book: overdue_book)

        get '/borrowings', params: { status: 'overdue' }, headers: auth_headers(librarian)

        expect(json_response.length).to eq(1)
        expect(json_response.first['due_date']).to be < Time.current.iso8601
      end
    end
  end

  describe 'GET /borrowings/:id' do
    let!(:borrowing) { create(:borrowing, user: sam, book: lotr_book) }

    context 'as Sam (owner)' do
      it 'shows borrowing details' do
        get "/borrowings/#{borrowing.id}", headers: auth_headers(sam)

        expect(response).to have_http_status(:ok)
        expect(json_response['book']['title']).to eq('The Lord of the Rings')
      end
    end

    context 'as Aragorn (different member)' do
      it 'cannot see Sam\'s borrowings' do
        get "/borrowings/#{borrowing.id}", headers: auth_headers(aragorn)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as Elrond (librarian)' do
      it 'can see any borrowing' do
        get "/borrowings/#{borrowing.id}", headers: auth_headers(librarian)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /borrowings/:id/return_book' do
    let!(:borrowing) { create(:borrowing, user: sam, book: lotr_book) }

    context 'as Elrond (librarian)' do
      it 'marks the book as returned (the journey is complete!)' do
        initial_available = lotr_book.available_copies

        patch "/borrowings/#{borrowing.id}/return_book", headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Book returned successfully')
        expect(json_response['borrowing']['returned_at']).to be_present

        # Check that available copies increased
        expect(lotr_book.reload.available_copies).to eq(initial_available + 1)
      end

      it 'prevents returning an already returned book' do
        borrowing.mark_as_returned!

        patch "/borrowings/#{borrowing.id}/return_book", headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Book has already been returned')
      end
    end

    context 'as Sam (member)' do
      it 'cannot mark book as returned (only librarians can do that)' do
        patch "/borrowings/#{borrowing.id}/return_book", headers: auth_headers(sam)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
