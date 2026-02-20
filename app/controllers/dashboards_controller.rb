class DashboardsController < ApplicationController
  def librarian
    authorize! :access, :librarian_dashboard

    overdue_borrowings = Borrowing.overdue.includes(:book, :user)
    recent_borrowings = Borrowing.includes(:book, :user).order(created_at: :desc).limit(10)

    render json: {
      total_books: Book.count,
      total_borrowed_books: Borrowing.active.count,
      books_due_today: Borrowing.due_today.count,
      overdue_books: overdue_borrowings.count,
      members_with_overdue_books: format_members_with_overdue_books(overdue_borrowings),
      recent_borrowings: format_overdue_borrowings(recent_borrowings)
    }, status: :ok
  end

  def member
    authorize! :access, :member_dashboard

    my_borrowings = current_user.borrowings.active.includes(:book)
    overdue_borrowings = current_user.borrowings.overdue.includes(:book)

    render json: {
      borrowed_books: format_borrowings_with_book_object(my_borrowings),
      overdue_books: format_borrowings_with_book_object(overdue_borrowings),
      borrowing_history: format_borrowings_with_book_object(current_user.borrowings.returned.includes(:book).limit(10))
    }, status: :ok
  end

  private

  def format_borrowings(borrowings)
    borrowings.map do |borrowing|
      {
        id: borrowing.id,
        book_id: borrowing.book.id,
        book_title: borrowing.book.title,
        book_author: borrowing.book.author,
        book_genre: borrowing.book.genre,
        book_isbn: borrowing.book.isbn,
        borrowed_at: borrowing.borrowed_at,
        due_date: borrowing.due_date,
        returned_at: borrowing.returned_at,
        days_overdue: borrowing.days_overdue
      }
    end
  end

  def format_borrowings_with_book_object(borrowings)
    borrowings.map do |borrowing|
      {
        id: borrowing.id,
        borrowed_at: borrowing.borrowed_at,
        due_date: borrowing.due_date,
        returned_at: borrowing.returned_at,
        days_overdue: borrowing.days_overdue,
        book: {
          id: borrowing.book.id,
          title: borrowing.book.title,
          author: borrowing.book.author,
          genre: borrowing.book.genre,
          isbn: borrowing.book.isbn
        }
      }
    end
  end

  def format_overdue_borrowings(borrowings)
    borrowings.map do |borrowing|
      {
        id: borrowing.id,
        book_id: borrowing.book.id,
        book_title: borrowing.book.title,
        book_author: borrowing.book.author,
        user_id: borrowing.user.id,
        user_name: borrowing.user.name,
        user_email: borrowing.user.email,
        borrowed_at: borrowing.borrowed_at,
        due_date: borrowing.due_date,
        days_overdue: borrowing.days_overdue
      }
    end
  end

  def format_members_with_overdue_books(overdue_borrowings)
    # Group by user and count overdue books
    overdue_by_user = overdue_borrowings.group_by(&:user)

    overdue_by_user.map do |user, borrowings|
      {
        id: user.id,
        name: user.name,
        email: user.email,
        overdue_count: borrowings.count,
        overdue_books: borrowings.map do |borrowing|
          {
            id: borrowing.id,
            book_id: borrowing.book.id,
            book_title: borrowing.book.title,
            due_date: borrowing.due_date,
            days_overdue: borrowing.days_overdue
          }
        end
      }
    end
  end
end
