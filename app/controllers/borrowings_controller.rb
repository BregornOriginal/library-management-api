class BorrowingsController < ApplicationController
  load_and_authorize_resource except: [:create, :return_book]
  before_action :set_borrowing, only: [:show, :return_book]

  def index
    @borrowings = if current_user.librarian?
                    Borrowing.includes(:user, :book).all
                  else
                    current_user.borrowings.includes(:book)
                  end

    @borrowings = @borrowings.active if params[:status] == 'active'
    @borrowings = @borrowings.returned if params[:status] == 'returned'
    @borrowings = @borrowings.overdue if params[:status] == 'overdue'

    render json: @borrowings.as_json(include: { book: {}, user: { only: [:id, :name, :email] } }), status: :ok
  end

  def show
    render json: @borrowing.as_json(include: { book: {}, user: { only: [:id, :name, :email] } }), status: :ok
  end

  def create
    @borrowing = current_user.borrowings.build(borrowing_create_params)

    if @borrowing.save
      render json: @borrowing.as_json(include: { book: {}, user: { only: [:id, :name, :email] } }),
             status: :created
    else
      render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def return_book
    authorize! :update, @borrowing

    if @borrowing.returned?
      render json: { error: 'Book has already been returned' }, status: :unprocessable_entity
    elsif @borrowing.mark_as_returned!
      render json: {
        message: 'Book returned successfully',
        borrowing: @borrowing.as_json(include: { book: {}, user: { only: [:id, :name, :email] } })
      }, status: :ok
    else
      render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_borrowing
    @borrowing = Borrowing.find(params[:id])
  end

  def borrowing_create_params
    params.require(:borrowing).permit(:book_id)
  end
end
