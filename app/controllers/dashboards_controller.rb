class DashboardsController < ApplicationController
  def librarian
    authorize! :access, :librarian_dashboard

    overdue_borrowings = Borrowing.overdue.includes(:book, :user)

    render json: {
      total_books: Book.count,
      total_borrowed_books: Borrowing.active.count,
      books_due_today: Borrowing.due_today.count,
      overdue_books: format_overdue_borrowings(overdue_borrowings)
    }, status: :ok
  end

  def member
    authorize! :access, :member_dashboard

    my_borrowings = current_user.borrowings.active.includes(:book)
    overdue_borrowings = current_user.borrowings.overdue.includes(:book)

    render json: {
      borrowed_books: format_borrowings(my_borrowings),
      overdue_books: format_borrowings(overdue_borrowings),
      borrowing_history: format_borrowings(current_user.borrowings.returned.includes(:book).limit(10))
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
end
