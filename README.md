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

### 3. Environment variables

Copy the example environment file and update it with your values:

```bash
cp .env.example .env
```

Generate a secure JWT secret key:

```bash
rails secret
```

Add the generated key to your `.env` file:

```
DEVISE_JWT_SECRET_KEY=your_generated_secret_here
```

### 4. Database setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 5. Run the server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## Authentication Endpoints

### Register (Sign Up)
- **POST** `/signup`
- **Body**:
  ```json
  {
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "member"
    }
  }
  ```
- **Response**: Returns user data and JWT token in `Authorization` header

### Login
- **POST** `/login`
- **Body**:
  ```json
  {
    "user": {
      "email": "john@example.com",
      "password": "password123"
    }
  }
  ```
- **Response**: Returns user data and JWT token in `Authorization` header

### Logout
- **DELETE** `/logout`
- **Headers**: `Authorization: Bearer <your_jwt_token>`
- **Response**: Success message

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
