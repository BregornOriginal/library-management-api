# Seeds for the Middle-earth Library Management System 📚🧙‍♂️
puts "🌋 Welcome to the Middle-earth Library System! 🌋"
puts "Clearing the One Database to rule them all..."

# Clear existing data
Borrowing.destroy_all
Book.destroy_all
User.destroy_all

puts "\n🧙‍♂️ Creating Librarians (The Wise Ones)..."

# Gandalf the Grey - Head Librarian of Rivendell
gandalf = User.create!(
  name: 'Gandalf the Grey',
  email: 'gandalf@middleearth.com',
  password: 'youshallnotpass',
  password_confirmation: 'youshallnotpass',
  role: :librarian
)
puts "✓ #{gandalf.name} has joined as librarian"

# Elrond - Lord of Rivendell and keeper of lore
elrond = User.create!(
  name: 'Elrond Half-elven',
  email: 'elrond@rivendell.com',
  password: 'imladris123',
  password_confirmation: 'imladris123',
  role: :librarian
)
puts "✓ #{elrond.name} has joined as librarian"

# Galadriel - Lady of Lothlorien
galadriel = User.create!(
  name: 'Galadriel',
  email: 'galadriel@lothlorien.com',
  password: 'lightofearendil',
  password_confirmation: 'lightofearendil',
  role: :librarian
)
puts "✓ #{galadriel.name} has joined as librarian"

puts "\n🏹 Creating Members (The Fellowship and Friends)..."

# The Hobbits
frodo = User.create!(
  name: 'Frodo Baggins',
  email: 'frodo@shire.com',
  password: 'thering123',
  password_confirmation: 'thering123',
  role: :member
)
puts "✓ #{frodo.name} - Ring Bearer"

sam = User.create!(
  name: 'Samwise Gamgee',
  email: 'sam@shire.com',
  password: 'potatoes123',
  password_confirmation: 'potatoes123',
  role: :member
)
puts "✓ #{sam.name} - Loyal Gardener"

merry = User.create!(
  name: 'Meriadoc Brandybuck',
  email: 'merry@shire.com',
  password: 'pipeweed123',
  password_confirmation: 'pipeweed123',
  role: :member
)
puts "✓ #{merry.name} - Knight of Rohan"

pippin = User.create!(
  name: 'Peregrin Took',
  email: 'pippin@shire.com',
  password: 'fooloftook123',
  password_confirmation: 'fooloftook123',
  role: :member
)
puts "✓ #{pippin.name} - Guard of the Citadel"

# Men
aragorn = User.create!(
  name: 'Aragorn son of Arathorn',
  email: 'strider@gondor.com',
  password: 'ranger123',
  password_confirmation: 'ranger123',
  role: :member
)
puts "✓ #{aragorn.name} - King of Gondor"

boromir = User.create!(
  name: 'Boromir',
  email: 'boromir@gondor.com',
  password: 'gondor123',
  password_confirmation: 'gondor123',
  role: :member
)
puts "✓ #{boromir.name} - Captain of Gondor"

# Elf
legolas = User.create!(
  name: 'Legolas Greenleaf',
  email: 'legolas@mirkwood.com',
  password: 'mirkwood123',
  password_confirmation: 'mirkwood123',
  role: :member
)
puts "✓ #{legolas.name} - Prince of Mirkwood"

# Dwarf
gimli = User.create!(
  name: 'Gimli son of Glóin',
  email: 'gimli@erebor.com',
  password: 'axes123',
  password_confirmation: 'axes123',
  role: :member
)
puts "✓ #{gimli.name} - Lord of the Glittering Caves"

puts "\n📚 Adding Books to the Library..."

# J.R.R. Tolkien's Works
lotr = Book.create!(
  title: 'The Lord of the Rings',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0544003415',
  total_copies: 10,
  available_copies: 10
)
puts "✓ #{lotr.title} - The One Book to Rule Them All"

fellowship = Book.create!(
  title: 'The Fellowship of the Ring',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0547928210',
  total_copies: 5,
  available_copies: 5
)
puts "✓ #{fellowship.title}"

two_towers = Book.create!(
  title: 'The Two Towers',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0547928203',
  total_copies: 5,
  available_copies: 5
)
puts "✓ #{two_towers.title}"

return_king = Book.create!(
  title: 'The Return of the King',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0547928197',
  total_copies: 5,
  available_copies: 5
)
puts "✓ #{return_king.title}"

hobbit = Book.create!(
  title: 'The Hobbit',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0547928227',
  total_copies: 8,
  available_copies: 8
)
puts "✓ #{hobbit.title} - There and Back Again"

silmarillion = Book.create!(
  title: 'The Silmarillion',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0618391110',
  total_copies: 3,
  available_copies: 3
)
puts "✓ #{silmarillion.title}"

unfinished_tales = Book.create!(
  title: 'Unfinished Tales',
  author: 'J.R.R. Tolkien',
  genre: 'Fantasy',
  isbn: '978-0618154043',
  total_copies: 2,
  available_copies: 2
)
puts "✓ #{unfinished_tales.title}"

# More Fantasy Books
game_of_thrones = Book.create!(
  title: 'A Game of Thrones',
  author: 'George R.R. Martin',
  genre: 'Fantasy',
  isbn: '978-0553103540',
  total_copies: 6,
  available_copies: 6
)
puts "✓ #{game_of_thrones.title}"

name_of_wind = Book.create!(
  title: 'The Name of the Wind',
  author: 'Patrick Rothfuss',
  genre: 'Fantasy',
  isbn: '978-0756404741',
  total_copies: 4,
  available_copies: 4
)
puts "✓ #{name_of_wind.title}"

way_of_kings = Book.create!(
  title: 'The Way of Kings',
  author: 'Brandon Sanderson',
  genre: 'Fantasy',
  isbn: '978-0765326355',
  total_copies: 4,
  available_copies: 4
)
puts "✓ #{way_of_kings.title}"

# Classic Literature
narnia = Book.create!(
  title: 'The Chronicles of Narnia',
  author: 'C.S. Lewis',
  genre: 'Fantasy',
  isbn: '978-0060598242',
  total_copies: 5,
  available_copies: 5
)
puts "✓ #{narnia.title}"

puts "\n🎒 Creating Some Borrowings..."

# Frodo borrowing LOTR (naturally)
borrowing1 = Borrowing.create!(
  user: frodo,
  book: lotr,
  borrowed_at: 2.days.ago,
  due_date: 12.days.from_now
)
puts "✓ Frodo is reading The Lord of the Rings (of course!)"

# Sam borrowing The Hobbit
borrowing2 = Borrowing.create!(
  user: sam,
  book: hobbit,
  borrowed_at: 1.week.ago,
  due_date: 1.week.from_now
)
puts "✓ Sam is reading The Hobbit"

# Aragorn with an overdue book
borrowing3 = Borrowing.create!(
  user: aragorn,
  book: fellowship,
  borrowed_at: 3.weeks.ago,
  due_date: 1.week.ago
)
puts "✓ Aragorn has The Fellowship of the Ring (overdue - he's been busy being king!)"

# Gimli borrowing fantasy
borrowing4 = Borrowing.create!(
  user: gimli,
  book: way_of_kings,
  borrowed_at: 3.days.ago,
  due_date: 11.days.from_now
)
puts "✓ Gimli is reading The Way of Kings"

# Legolas with a returned book
borrowing5 = Borrowing.create!(
  user: legolas,
  book: name_of_wind,
  borrowed_at: 1.month.ago,
  due_date: 2.weeks.ago,
  returned_at: 1.week.ago
)
puts "✓ Legolas returned The Name of the Wind (such an elf, always on time!)"

# Merry with due today
borrowing6 = Borrowing.create!(
  user: merry,
  book: two_towers,
  borrowed_at: 2.weeks.ago,
  due_date: Time.current.end_of_day
)
puts "✓ Merry's The Two Towers is due today!"

puts "\n" + "="*60
puts "🎉 Middle-earth Library System initialized successfully! 🎉"
puts "="*60
puts "\n📖 Library Statistics:"
puts "   Total Books: #{Book.count}"
puts "   Total Users: #{User.count}"
puts "   Librarians: #{User.librarian.count}"
puts "   Members: #{User.member.count}"
puts "   Active Borrowings: #{Borrowing.active.count}"
puts "   Overdue Books: #{Borrowing.overdue.count}"
puts "\n🔐 Demo Credentials:"
puts "\n   Librarian (Gandalf):"
puts "   Email: gandalf@middleearth.com"
puts "   Password: youshallnotpass"
puts "\n   Member (Frodo):"
puts "   Email: frodo@shire.com"
puts "   Password: thering123"
puts "\n🚀 The library is ready for adventure!"
puts "   May your API calls be swift and your responses successful!"
puts "="*60
