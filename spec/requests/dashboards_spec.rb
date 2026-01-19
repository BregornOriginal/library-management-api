require 'rails_helper'

RSpec.describe 'Dashboards API', type: :request do
  # Saruman the White - head librarian of Isengard
  let(:librarian) { create(:user, :librarian, name: 'Saruman', email: 'saruman@isengard.com') }

  # Pippin - member who sometimes borrows books he shouldn't
  let(:member) { create(:user, :member, name: 'Peregrin Took', email: 'pippin@shire.com') }

  # Merry - another member with overdue books
  let(:merry) { create(:user, :member, name: 'Meriadoc Brandybuck', email: 'merry@shire.com') }

  let!(:books) { create_list(:book, 5) }
  let!(:active_borrowing) { create(:borrowing, user: member, book: books[0]) }
  let!(:overdue_borrowing) { create(:borrowing, :overdue, user: merry, book: books[1]) }
  let!(:due_today_borrowing) { create(:borrowing, :due_today, user: member, book: books[2]) }
  let!(:returned_borrowing) { create(:borrowing, :returned, user: member, book: books[3]) }

  describe 'GET /dashboard/librarian' do
    context 'as Saruman (librarian)' do
      it 'shows the grand overview of Isengard library' do
        get '/dashboard/librarian', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)

        # Check all the stats
        expect(json_response['total_books']).to eq(5)
        expect(json_response['total_borrowed_books']).to eq(3) # active + overdue + due today
        expect(json_response['books_due_today']).to eq(1)
        expect(json_response['overdue_books']).to eq(1)
      end

      it 'lists members with overdue books (those who need a reminder!)' do
        get '/dashboard/librarian', headers: auth_headers(librarian)

        expect(json_response['members_with_overdue_books']).to be_an(Array)
        expect(json_response['members_with_overdue_books'].length).to eq(1)

        overdue_member = json_response['members_with_overdue_books'].first
        expect(overdue_member['name']).to eq('Meriadoc Brandybuck')
        expect(overdue_member['overdue_count']).to eq(1)
        expect(overdue_member['overdue_books']).to be_present
      end

      it 'shows recent borrowings across all of Middle-earth' do
        get '/dashboard/librarian', headers: auth_headers(librarian)

        expect(json_response['recent_borrowings']).to be_an(Array)
        expect(json_response['recent_borrowings'].length).to be > 0
      end
    end

    context 'as Pippin (member)' do
      it 'denies access (only wizards can see this view!)' do
        get '/dashboard/librarian', headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without authentication' do
      it 'requires authentication' do
        get '/dashboard/librarian'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /dashboard/member' do
    context 'as Pippin (member)' do
      it 'shows Pippin\'s personal library dashboard' do
        get '/dashboard/member', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)

        # Check borrowed books
        expect(json_response['borrowed_books']).to be_an(Array)
        expect(json_response['borrowed_books'].length).to eq(2) # active + due today

        # Check overdue books
        expect(json_response['overdue_books']).to be_an(Array)

        # Check borrowing history
        expect(json_response['borrowing_history']).to be_an(Array)
        expect(json_response['borrowing_history'].length).to eq(1) # the returned one
      end

      it 'includes book details in borrowed books' do
        get '/dashboard/member', headers: auth_headers(member)

        borrowed_book = json_response['borrowed_books'].first
        expect(borrowed_book).to have_key('book')
        expect(borrowed_book['book']).to have_key('title')
        expect(borrowed_book['book']).to have_key('author')
      end
    end

    context 'as Merry with overdue books' do
      it 'shows overdue books (time to return them!)' do
        get '/dashboard/member', headers: auth_headers(merry)

        expect(response).to have_http_status(:ok)
        expect(json_response['overdue_books'].length).to eq(1)
      end
    end

    context 'as Saruman (librarian)' do
      it 'denies access (librarians have their own dashboard)' do
        get '/dashboard/member', headers: auth_headers(librarian)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without authentication' do
      it 'requires authentication' do
        get '/dashboard/member'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
