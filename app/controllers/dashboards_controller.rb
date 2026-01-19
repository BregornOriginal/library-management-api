class DashboardsController < ApplicationController
  def librarian
    authorize! :access, :librarian_dashboard

    render json: {
      total_books: Book.count,
      total_borrowed_books: Borrowing.active.count,
      books_due_today: Borrowing.due_today.count,
      overdue_books: Borrowing.overdue.count,
      members_with_overdue_books: members_with_overdue_books,
      recent_borrowings: recent_borrowings
    }, status: :ok
  end

  def member
    authorize! :access, :member_dashboard

    my_borrowings = current_user.borrowings.active.includes(:book)

    render json: {
      borrowed_books: my_borrowings.as_json(include: :book),
      overdue_books: current_user.borrowings.overdue.as_json(include: :book),
      borrowing_history: current_user.borrowings.returned.limit(10).as_json(include: :book)
    }, status: :ok
  end

  private

  def members_with_overdue_books
    User.joins(:borrowings)
        .where(borrowings: { returned_at: nil })
        .where('borrowings.due_date < ?', Time.current)
        .distinct
        .select(:id, :name, :email)
        .map do |user|
          {
            id: user.id,
            name: user.name,
            email: user.email,
            overdue_count: user.borrowings.overdue.count,
            overdue_books: user.borrowings.overdue.includes(:book).map do |borrowing|
              {
                book_title: borrowing.book.title,
                due_date: borrowing.due_date,
                days_overdue: borrowing.days_overdue
              }
            end
          }
        end
  end

  def recent_borrowings
    Borrowing.includes(:user, :book)
             .order(created_at: :desc)
             .limit(10)
             .as_json(include: {
               book: { only: [:id, :title, :author] },
               user: { only: [:id, :name, :email] }
             })
  end
end
