class BooksController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @books = if params[:search].present?
               search_books
             else
               Book.all
             end

    render json: @books, status: :ok
  end

  def show
    render json: @book, status: :ok
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    head :no_content
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies, :available_copies)
  end

  def search_books
    query = params[:search]
    scope = params[:search_by]

    case scope
    when 'title'
      Book.search_by_title(query)
    when 'author'
      Book.search_by_author(query)
    when 'genre'
      Book.search_by_genre(query)
    else
      # Search across all fields
      Book.where(
        'title ILIKE ? OR author ILIKE ? OR genre ILIKE ?',
        "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end
  end
end
