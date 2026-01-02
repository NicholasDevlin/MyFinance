# MyFinance - Personal Finance Management App

A full-stack personal finance management application built with Flutter (frontend) and NestJS (backend), featuring comprehensive expense tracking, income management, and financial insights.

## 🚀 Features

### User Management
- **User Registration & Authentication**: JWT-based secure authentication
- **User Profile Management**: Manage personal information and preferences
<img width="200" alt="image" src="https://github.com/user-attachments/assets/99df134f-fa0c-40b3-b489-18dc3c5d79c1" />

### Account Management
- **Multiple Account Types**: Support for bank accounts, cash, credit cards, and e-wallets
- **Real-time Balance Tracking**: Automatic balance updates based on transactions
- **Account Overview**: Visual representation of all accounts and total balance
<img width="200" alt="image" src="https://github.com/user-attachments/assets/92bc75cb-abb0-4878-8111-00aaa1e72557" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/86894349-4207-4336-87ee-c50a497b3498" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/52abd667-6a6e-4663-8fd9-36e436856b47" />

### Transaction Management
- **Income Tracking**: Record income with amount, date, source, and category
- **Expense Tracking**: Track expenses with receipt image upload support
- **Transaction Categories**: Predefined and custom categories for better organization
- **Transaction History**: Comprehensive list with filtering and search capabilities
<img width="200" alt="image" src="https://github.com/user-attachments/assets/bb202c61-0ede-429e-9eb6-394d79ee118d" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/cc7a4068-b864-404e-b4cf-6977f3624359" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/3f4d90a2-15cc-4fd9-9320-8ab7d763d337" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/ab5a71f8-af79-4a46-b058-2a3a26906c01" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/bc16221f-036d-41c1-a92a-ebc502f9ca75" />

### Dashboard & Analytics
- **Monthly Overview**: Income vs expenses comparison charts
- **Spending Analytics**: Category-wise spending breakdown
- **Balance Trends**: Visual representation of financial health
- **Quick Statistics**: Key financial metrics at a glance
<img width="200" alt="image" src="https://github.com/user-attachments/assets/ba521a3c-fdec-4099-90e9-3d8b25249a04" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/c0848840-f4eb-43eb-9bee-3ae6b280b051" />


## 🛠 Tech Stack

### Backend (NestJS)
- **Framework**: NestJS with TypeScript
- **Database**: MySQL with TypeORM
- **Authentication**: JWT with Passport
- **File Upload**: Multer for receipt images
- **API**: RESTful APIs with comprehensive validation

### Frontend (Flutter)
- **Framework**: Flutter for Android
- **State Management**: Provider pattern
- **HTTP Client**: Dio for API communication
- **UI**: Material Design 3
- **Charts**: FL Chart for data visualization
- **Image Handling**: Image picker for receipt uploads

## 📁 Project Structure

```
myfinance/
├── backend/                 # NestJS Backend
│   ├── src/
│   │   ├── auth/           # Authentication module
│   │   ├── users/          # User management
│   │   ├── accounts/       # Account management
│   │   ├── transactions/   # Transaction handling
│   │   ├── categories/     # Category management
│   │   ├── dashboard/      # Dashboard APIs
│   │   └── main.ts         # Application entry point
│   ├── uploads/            # Receipt image storage
│   ├── package.json
│   └── .env.example
│
└── frontend/               # Flutter Frontend
    ├── lib/
    │   ├── models/         # Data models
    │   ├── providers/      # State management
    │   ├── screens/        # UI screens
    │   ├── services/       # API services
    │   ├── theme/          # App theming
    │   ├── widgets/        # Reusable components
    │   └── main.dart       # App entry point
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- Flutter SDK (v3.0 or higher)
- Android Studio / VS Code

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your database credentials:
   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_USERNAME=root
   DB_PASSWORD=your_password
   DB_NAME=myfinance
   JWT_SECRET=your_jwt_secret
   ```

4. **Create MySQL database**
   ```sql
   CREATE DATABASE myfinance;
   ```

5. **Start the server**
   ```bash
   npm run start:dev
   ```
   Server will run on `http://localhost:3000`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API endpoint** (if needed)
   Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
   // static const String baseUrl = 'http://localhost:3000'; // iOS simulator
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Screens

### Authentication
- **Login Screen**: Email/password authentication
- **Register Screen**: New user registration with optional profile info

### Main Navigation
- **Dashboard**: Financial overview with charts and summaries
- **Transactions**: Complete transaction history with filtering
- **Accounts**: Account management and balance tracking
- **Profile**: User settings and preferences

### Transaction Management
- **Add Income**: Income entry with categorization
- **Add Expense**: Expense tracking with receipt upload
- **Transaction Details**: Comprehensive transaction information

### Account Management
- **Add Account**: Create new financial accounts
- **Account List**: Overview of all accounts with balances
- **Account Details**: Individual account management

## 🎨 Design Features

- **Material Design 3**: Modern, consistent UI design
- **Responsive Layout**: Optimized for various screen sizes
- **Color-coded Categories**: Visual distinction for different transaction types
- **Interactive Charts**: Engaging data visualization
- **Dark/Light Theme Support**: User preference accommodation

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt for secure password storage
- **Input Validation**: Comprehensive data validation
- **File Upload Security**: Image file type and size validation
- **API Rate Limiting**: Protection against abuse

## 📊 Database Schema

### Users Table
- User credentials and profile information
- Relationships to accounts and transactions

### Accounts Table
- Financial account details with balance tracking
- Support for multiple account types

### Transactions Table
- Complete transaction records with metadata
- Foreign keys to users, accounts, and categories
- Optional receipt image storage

### Categories Table
- Predefined and custom transaction categories
- Color coding for visual organization

## 🚀 Deployment

### Backend Deployment
1. Set up production MySQL database
2. Configure environment variables
3. Build the application: `npm run build`
4. Start production server: `npm run start:prod`

### Frontend Deployment
1. Build release APK: `flutter build apk --release`
2. Install on Android device or upload to Play Store

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team

## 📡 API Endpoints

The MyFinance backend provides a comprehensive RESTful API with the following endpoints:

### 🔐 Authentication (`/auth`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `POST` | `/auth/register` | Register new user | None |
| `POST` | `/auth/login` | Login user | None |
| `GET` | `/auth/profile` | Get current user profile | JWT Required |

### 👤 Users (`/users`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `GET` | `/users/profile` | Get current user profile | JWT Required |
| `PATCH` | `/users/profile` | Update current user profile | JWT Required |
| `GET` | `/users/:id` | Get user by ID | JWT Required |
| `PATCH` | `/users/:id` | Update user by ID | JWT Required |
| `DELETE` | `/users/:id` | Delete user by ID | JWT Required |

### 🏦 Accounts (`/accounts`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `POST` | `/accounts` | Create new account | JWT Required |
| `GET` | `/accounts` | Get all user accounts | JWT Required |
| `GET` | `/accounts/total-balance` | Get total balance across all accounts | JWT Required |
| `GET` | `/accounts/:id` | Get account by ID | JWT Required |
| `PATCH` | `/accounts/:id` | Update account | JWT Required |
| `DELETE` | `/accounts/:id` | Delete account (soft delete) | JWT Required |
| `POST` | `/accounts/:id/restore` | Restore soft deleted account | JWT Required |
| `GET` | `/accounts/deleted` | Get all soft deleted accounts | JWT Required |

### 🏷️ Categories (`/categories`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `POST` | `/categories` | Create new category | JWT Required |
| `GET` | `/categories` | Get all categories | JWT Required |
| `GET` | `/categories?type={type}` | Filter categories by type | JWT Required |
| `GET` | `/categories/:id` | Get category by ID | JWT Required |
| `PATCH` | `/categories/:id` | Update category | JWT Required |
| `DELETE` | `/categories/:id` | Delete category | JWT Required |

### 💳 Transactions (`/transactions`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `POST` | `/transactions` | Create transaction with optional receipt upload | JWT Required |
| `GET` | `/transactions` | Get transactions with filters & pagination | JWT Required |
| `GET` | `/transactions/summary/:year/:month` | Get monthly summary | JWT Required |
| `GET` | `/transactions/:id` | Get transaction by ID | JWT Required |
| `PATCH` | `/transactions/:id` | Update transaction with optional receipt | JWT Required |
| `DELETE` | `/transactions/:id` | Delete transaction | JWT Required |

#### Transaction Query Parameters
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10, max: 100)
- `type` - Filter by transaction type (`INCOME`, `EXPENSE`)
- `accountId` - Filter by account ID
- `categoryId` - Filter by category ID
- `startDate` - Start date filter (ISO string)
- `endDate` - End date filter (ISO string)

### 📊 Dashboard (`/dashboard`)
| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `GET` | `/dashboard` | Get main dashboard data | JWT Required |
| `GET` | `/dashboard/yearly/:year` | Get yearly overview | JWT Required |
| `GET` | `/dashboard/spending-by-category` | Get spending by category | JWT Required |

### 📎 File Uploads
- Receipt images are uploaded via multipart form data
- Supported formats: JPG, PNG, GIF
- Files are automatically renamed with format: `receipt-{timestamp}-{random}.{ext}`
- Accessible via: `GET /uploads/receipts/{filename}`

### 🔒 Authentication
- Most endpoints require JWT authentication
- Include JWT token in Authorization header: `Bearer <token>`
- Tokens are obtained via `/auth/login` endpoint

## 🎯 Future Enhancements

- **Budgeting**: Set and track spending budgets
- **Bill Reminders**: Recurring transaction notifications
- **Export Features**: PDF reports and CSV exports
- **Multi-currency**: Support for different currencies
- **Investment Tracking**: Portfolio management features
- **Shared Accounts**: Family/group account management

---

**MyFinance** - Take control of your financial future! 💰📱
