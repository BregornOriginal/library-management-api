# Library Management System API

A Ruby on Rails REST API for managing a library system with book borrowing and returning capabilities.

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 7.1.6
- **Database**: PostgreSQL
- **Authentication**: Devise + JWT
- **Authorization**: CanCanCan
- **Testing**: RSpec

## Prerequisites

- Ruby 3.2.2
- PostgreSQL
- Bundler

## Setup Instructions

### 1. Clone the repository

```bash
git clone <repository-url>
cd library-management-api
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Database setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Run the server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## API Documentation

_(Coming soon)_

## Demo Credentials

_(Coming soon after seeding)_

## License

All rights reserved.
