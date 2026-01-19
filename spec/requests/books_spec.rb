require 'rails_helper'

RSpec.describe 'Books API', type: :request do
  # Gandalf the Grey - wise librarian of Rivendell
  let(:librarian) { create(:user, :librarian, name: 'Gandalf', email: 'gandalf@middleearth.com') }

  # Frodo Baggins - curious member from the Shire
  let(:member) { create(:user, :member, name: 'Frodo Baggins', email: 'frodo@shire.com') }

  # The One Book to Rule Them All
  let!(:lotr_book) do
    create(:book,
           title: 'The Lord of the Rings',
           author: 'J.R.R. Tolkien',
           genre: 'Fantasy',
           isbn: '978-0544003415',
           total_copies: 3,
           available_copies: 3)
  end

  let!(:hobbit_book) do
    create(:book,
           title: 'The Hobbit',
           author: 'J.R.R. Tolkien',
           genre: 'Fantasy',
           isbn: '978-0547928227')
  end

  let!(:silmarillion_book) do
    create(:book,
           title: 'The Silmarillion',
           author: 'J.R.R. Tolkien',
           genre: 'Fantasy',
           isbn: '978-0618391110')
  end

  describe 'GET /books' do
    context 'without authentication' do
      it 'returns all books from Middle-earth' do
        get '/books'
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(3)
      end
    end

    context 'with authentication' do
      it 'allows Frodo to browse the library' do
        get '/books', headers: auth_headers(member)
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(3)
      end
    end

    context 'with search parameters' do
      it 'finds books by title' do
        get '/books', params: { search: 'Hobbit', search_by: 'title' }
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(1)
        expect(json_response.first['title']).to eq('The Hobbit')
      end

      it 'finds books by author (Tolkien)' do
        get '/books', params: { search: 'Tolkien', search_by: 'author' }
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(3)
      end

      it 'finds books by genre (Fantasy)' do
        get '/books', params: { search: 'Fantasy', search_by: 'genre' }
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(3)
      end

      it 'searches across all fields' do
        get '/books', params: { search: 'Silmarillion' }
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(1)
      end
    end
  end

  describe 'GET /books/:id' do
    it 'returns details of The One Ring... I mean, The Lord of the Rings' do
      get "/books/#{lotr_book.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response['title']).to eq('The Lord of the Rings')
      expect(json_response['author']).to eq('J.R.R. Tolkien')
    end

    it 'returns 404 when book not found (lost in Mordor perhaps?)' do
      get '/books/99999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /books' do
    let(:new_book_params) do
      {
        book: {
          title: 'The Fellowship of the Ring',
          author: 'J.R.R. Tolkien',
          genre: 'Fantasy',
          isbn: '978-0547928210',
          total_copies: 5,
          available_copies: 5
        }
      }
    end

    context 'as Gandalf (librarian)' do
      it 'adds a new book to the library' do
        expect {
          post '/books', params: new_book_params, headers: auth_headers(librarian)
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq('The Fellowship of the Ring')
      end
    end

    context 'as Frodo (member)' do
      it 'cannot add books (only wizards can do that!)' do
        post '/books', params: new_book_params, headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without authentication' do
      it 'denies access (you shall not pass!)' do
        post '/books', params: new_book_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid data' do
      it 'returns validation errors' do
        invalid_params = { book: { title: '' } }
        post '/books', params: invalid_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'PUT /books/:id' do
    let(:update_params) do
      {
        book: {
          total_copies: 10,
          available_copies: 8
        }
      }
    end

    context 'as Gandalf (librarian)' do
      it 'updates book details' do
        put "/books/#{lotr_book.id}", params: update_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:ok)
        expect(json_response['total_copies']).to eq(10)
      end
    end

    context 'as Frodo (member)' do
      it 'cannot update books' do
        put "/books/#{lotr_book.id}", params: update_params, headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /books/:id' do
    context 'as Gandalf (librarian)' do
      it 'removes a book from the library' do
        expect {
          delete "/books/#{lotr_book.id}", headers: auth_headers(librarian)
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'as Frodo (member)' do
      it 'cannot delete books (even if they want to throw them into Mount Doom)' do
        delete "/books/#{lotr_book.id}", headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
