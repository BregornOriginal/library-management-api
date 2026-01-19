class Book < ApplicationRecord
  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :available_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :available_copies_cannot_exceed_total_copies

  scope :available, -> { where('available_copies > 0') }
  scope :search_by_title, ->(query) { where('title ILIKE ?', "%#{query}%") }
  scope :search_by_author, ->(query) { where('author ILIKE ?', "%#{query}%") }
  scope :search_by_genre, ->(query) { where('genre ILIKE ?', "%#{query}%") }

  def available?
    available_copies > 0
  end

  def borrow!
    raise StandardError, 'No copies available' unless available?

    decrement!(:available_copies)
  end

  def return!
    increment!(:available_copies) if available_copies < total_copies
  end

  private

  def available_copies_cannot_exceed_total_copies
    if available_copies && total_copies && available_copies > total_copies
      errors.add(:available_copies, "cannot exceed total copies")
    end
  end
end
