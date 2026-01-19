class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validate :user_cannot_borrow_same_book_multiple_times, on: :create
  validate :book_must_be_available, on: :create

  before_validation :set_dates, on: :create
  after_create :decrease_book_availability
  after_update :increase_book_availability, if: :returned?

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { active.where('due_date < ?', Time.current) }
  scope :due_today, -> { active.where('DATE(due_date) = ?', Date.today) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  def returned?
    returned_at.present?
  end

  def overdue?
    !returned? && due_date < Time.current
  end

  def mark_as_returned!
    update!(returned_at: Time.current)
  end

  def days_overdue
    return 0 unless overdue?

    ((Time.current - due_date) / 1.day).to_i
  end

  private

  def set_dates
    self.borrowed_at ||= Time.current
    self.due_date ||= borrowed_at + 2.weeks
  end

  def user_cannot_borrow_same_book_multiple_times
    if user && book
      existing = Borrowing.active.exists?(user_id: user.id, book_id: book.id)
      errors.add(:base, "You have already borrowed this book") if existing
    end
  end

  def book_must_be_available
    errors.add(:book, "is not available") if book && !book.available?
  end

  def decrease_book_availability
    book.borrow!
  end

  def increase_book_availability
    book.return!
  end
end
