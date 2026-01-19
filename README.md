# 📚 Library Management System API

A Ruby on Rails REST API for managing a library with book borrowing, returns, and LOTR-themed demo data! 🧙‍♂️

**Frontend Repository:** [library-management-frontend](https://github.com/BregornOriginal/library-management-frontend)

## 🛠️ Tech Stack

Ruby 3.2.2 • Rails 7.1.6 (API) • PostgreSQL • Devise + JWT • CanCanCan • RSpec

## 🚀 Quick Start

```bash
# Install dependencies
bundle install

# Setup environment variable (optional for dev)
rails secret  # Generate a key
echo "DEVISE_JWT_SECRET_KEY=your_key" > .env

# Setup database
rails db:create db:migrate db:seed

# Run tests (121 tests, all passing!)
bundle exec rspec

# Start server
rails server  # API runs on http://localhost:3000
```

### Frontend Repository
👉 **[Library Management Frontend](https://github.com/BregornOriginal/library-management-frontend)**

```bash
# Clone and start the React frontend
git clone https://github.com/BregornOriginal/library-management-frontend.git
cd library-management-frontend
npm install
npm start  # Runs on http://localhost:3001
```

## 🔐 Demo Credentials (LOTR Characters!)

```
Librarian (Gandalf):  gandalf@middleearth.com / youshallnotpass
Member (Frodo):       frodo@shire.com / thering123
Member (Sam):         sam@shire.com / potatoes123
```

**More characters available:** Aragorn, Legolas, Gimli, Merry, Pippin, Elrond, Galadriel

## 📡 API Endpoints

### Authentication
| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/signup` | POST | Register new user | No |
| `/login` | POST | Login and get JWT token | No |
| `/logout` | DELETE | Logout | Yes |

**Roles:** `member` or `librarian`

### Books
| Endpoint | Method | Description | Auth | Who |
|----------|--------|-------------|------|-----|
| `/books` | GET | List/search books | No | Public |
| `/books/:id` | GET | Show book | No | Public |
| `/books` | POST | Create book | Yes | Librarian |
| `/books/:id` | PUT | Update book | Yes | Librarian |
| `/books/:id` | DELETE | Delete book | Yes | Librarian |

**Search:** `/books?search=tolkien&search_by=author` (search_by: title/author/genre)

### Borrowings
| Endpoint | Method | Description | Auth | Who |
|----------|--------|-------------|------|-----|
| `/borrowings` | GET | List borrowings | Yes | Own or All* |
| `/borrowings/:id` | GET | Show borrowing | Yes | Own or All* |
| `/borrowings` | POST | Borrow book | Yes | Member |
| `/borrowings/:id/return_book` | PATCH | Return book | Yes | Librarian |

*Members see own, Librarians see all. Filter by: `?status=active|returned|overdue`

### Dashboards
| Endpoint | Method | Description | Auth | Who |
|----------|--------|-------------|------|-----|
| `/dashboard/librarian` | GET | Stats & overdue list | Yes | Librarian |
| `/dashboard/member` | GET | My books & history | Yes | Member |

## 💡 Usage Examples

```bash
# 1. Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"frodo@shire.com","password":"thering123"}}'
# Save JWT from Authorization header

# 2. Search books
curl "http://localhost:3000/books?search=tolkien&search_by=author"

# 3. Borrow a book
curl -X POST http://localhost:3000/borrowings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"borrowing":{"book_id":1}}'

# 4. View dashboard
curl http://localhost:3000/dashboard/member \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ⚙️ Business Rules

**Borrowing:**
- Members borrow available books (2-week due date)
- Can't borrow same book twice
- Librarians mark returns

**Authorization:**
- Public: View books
- Members: Borrow & view own borrowings
- Librarians: Manage books & all borrowings

**Features:**
- 121 passing RSpec tests
- Automatic availability tracking
- Overdue detection
- Search by title/author/genre
- CORS enabled for frontend

---

## 📚 What's Included

**Seed Data:** 11 books (LOTR + fantasy classics), 11 users (Fellowship members!), sample borrowings

**Database:** PostgreSQL with optimized indexes on isbn, title, author, due_date

**Test Coverage:** 121 examples across models, requests, and authentication
