# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Guest user (not logged in)

    if user.librarian?
      # Librarians are like Gandalf - they have great power and responsibility! 🧙‍♂️
      can :manage, Book
      can :create, Borrowing
      can :update, Borrowing # Can mark books as returned
      can :read, Borrowing
      can :read, User
      can :access, :librarian_dashboard
    elsif user.member?
      # Members are like hobbits - they can read and borrow, but with limitations
      can :read, Book
      can :create, Borrowing, user_id: user.id
      can :read, Borrowing, user_id: user.id
      can :access, :member_dashboard
    end

    # Everyone can search for books (even Gollum wants to find his precious books)
    can :search, Book
  end
end
