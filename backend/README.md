# MyFinance Backend

NestJS-based REST API for the MyFinance personal finance management application.

## Features

- User authentication with JWT
- Account management (bank, cash, credit card, e-wallet)
- Transaction tracking with receipt upload
- Category management
- Dashboard analytics
- MySQL database with TypeORM

## Installation

```bash
npm install
```

## Configuration

1. Copy `.env.example` to `.env`
2. Configure your database credentials
3. Set JWT secret

## Database Setup

```sql
CREATE DATABASE myfinance;
```

## Running the app

```bash
# development
npm run start

# watch mode
npm run start:dev

# production mode
npm run start:prod
```

## API Documentation

The API provides the following endpoints:

### Authentication
- POST `/auth/register` - Register new user
- POST `/auth/login` - Login user
- GET `/users/profile` - Get user profile

### Accounts
- GET `/accounts` - Get user accounts
- POST `/accounts` - Create account
- PATCH `/accounts/:id` - Update account
- DELETE `/accounts/:id` - Delete account

### Transactions
- GET `/transactions` - Get transactions
- POST `/transactions` - Create transaction (with file upload)
- PATCH `/transactions/:id` - Update transaction
- DELETE `/transactions/:id` - Delete transaction

### Categories
- GET `/categories` - Get categories
- POST `/categories` - Create category

### Dashboard
- GET `/dashboard` - Get dashboard data
- GET `/dashboard/yearly/:year` - Get yearly overview
- GET `/dashboard/spending-by-category` - Get spending breakdown