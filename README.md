# Kibernum Ecommerce Backend

A robust Ruby on Rails API backend for an ecommerce platform, built as a technical test. This application provides comprehensive product management, customer tracking, purchase processing, and administrative features with JWT authentication and audit logging.

## 🚀 Features

### Core Functionality
- **Product Management**: CRUD operations for products with categories and images
- **Customer Management**: Customer registration and profile management
- **Purchase Processing**: Order creation and management
- **Category Management**: Product categorization system
- **User Authentication**: JWT-based authentication system
- **Role-based Access Control**: Admin and regular user roles

### Advanced Features
- **Audit System**: Complete tracking of all admin actions on products and categories
- **Email Notifications**: First purchase notifications and daily reports
- **Caching**: Redis-based caching for improved performance
- **Background Jobs**: Asynchronous processing for reports and notifications
- **API Documentation**: Comprehensive API endpoints with examples

## 🛠 Tech Stack

- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Caching**: Redis
- **Background Jobs**: Active Job with Redis adapter
- **Email**: Action Mailer with SMTP
- **Testing**: RSpec
- **Code Quality**: RuboCop

## 📋 Prerequisites

- Ruby 3.2.2 or higher
- PostgreSQL 12 or higher
- Redis 6 or higher

## 🔧 Installation & Setup

### 1. Clone the repository
```bash
git clone <repository-url>
cd kibernum-ecommerce
```

### 2. Install dependencies
```bash
bundle install
```

### 3. Database setup
```bash
# Create and setup database
rails db:create
rails db:migrate
rails db:seed
```

### 4. Environment configuration
Copy the example environment file and configure your settings:
```bash
cp .env.example .env
# Edit .env with your database, Redis, and email settings
```

### 5. Start the application
```bash
# Start the Rails server
rails server

# In another terminal, start Redis (if not running as a service)
redis-server

# Start background job processor
rails jobs:work
```

The application will be available at `http://localhost:3000`

## 🧪 Testing

Run the test suite:
```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 📚 API Documentation

### Authentication

All API endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Base URL
```
http://localhost:3000/api/v1
```

### 1. Authentication Endpoints

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "admin"
  }
}
```

#### Register
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

### 2. Product Management

#### List Products
```http
GET /products
Authorization: Bearer <token>
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 20)
- `category_id`: Filter by category
- `search`: Search by name or description

**Response:**
```json
{
  "products": [
    {
      "id": 1,
      "name": "iPhone 15 Pro",
      "description": "Latest iPhone model",
      "price": "999.99",
      "stock": 50,
      "category": {
        "id": 1,
        "name": "Electronics"
      },
      "images": [
        {
          "id": 1,
          "url": "https://example.com/iphone.jpg"
        }
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100
  }
}
```

### 3. Purchase Management

#### Create Purchase
```http
POST /purchases
Authorization: Bearer <token>
Content-Type: application/json

{
  "customer": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  },
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 3,
      "quantity": 1
    }
  ]
}
```

**Response:**
```json
{
  "purchase": {
    "id": 1,
    "total_amount": "2099.97",
    "status": "completed",
    "customer": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "items": [
      {
        "product": {
          "id": 1,
          "name": "iPhone 15 Pro",
          "price": "999.99"
        },
        "quantity": 2,
        "subtotal": "1999.98"
      }
    ],
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### List Purchases (Admin only)
```http
GET /purchases
Authorization: Bearer <admin-token>
```

### 4. Audit Logs (Admin only)

#### List Activity Logs
```http
GET /activity_logs
Authorization: Bearer <admin-token>
```

**Query Parameters:**
- `user_id`: Filter by user
- `scope_type`: Filter by scope type (Product, Category)
- `scope_id`: Filter by specific scope ID
- `action`: Filter by action (create, update, destroy)
- `page`: Page number
- `per_page`: Items per page

**Response:**
```json
{
  "activity_logs": [
    {
      "id": 1,
      "action": "create",
      "scope_type": "Product",
      "scope_name": "New Product",
      "user_name": "Admin User",
      "formatted_changes": "Created product 'New Product'",
      "changes_summary": {
        "created": {
          "name": "New Product",
          "price": "99.99"
        }
      },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 1
  }
}
```

## 🔐 Authentication & Authorization

### User Roles
- **Admin**: Full access to all endpoints, can manage products, categories, and view audit logs
- **Regular User**: Can view products and create purchases

### JWT Token Structure
The JWT token contains:
- User ID
- Email
- Role
- Expiration time (24 hours)

## 📧 Email Notifications

### First Purchase Notification
When a customer makes their first purchase, an email notification is sent to the customer with order details.

### Daily Purchase Reports
Admin users receive daily reports at midnight (GMT-5) containing:
- Total purchases for the day
- Revenue summary
- Top products by revenue and quantity
- Purchases by category
- Top customers

## 🔍 Audit System

The audit system tracks all administrative actions:
- **Product Changes**: Create, update, delete operations
- **Category Changes**: Create, update, delete operations
- **Change Details**: Before and after states for updates
- **User Tracking**: Which admin performed each action
- **Timestamps**: When each action occurred

## 🚀 Background Jobs

### Daily Report Job
- **Schedule**: Daily at midnight (GMT-5)
- **Purpose**: Generate and email daily purchase reports to admins
- **Queue**: `default`

### First Purchase Notification
- **Trigger**: When a customer makes their first purchase
- **Purpose**: Send welcome email with order details
- **Queue**: `default`

## 💾 Caching

The application uses Redis for caching:
- **Product Lists**: Cached with pagination and filter parameters
- **Category Lists**: Cached for improved performance
- **Audit Logs**: Cached with proper invalidation on new logs

## 📊 Database Schema

### Key Tables
- `users`: User accounts and authentication
- `products`: Product catalog
- `categories`: Product categories
- `customers`: Customer information
- `purchases`: Order records
- `activity_logs`: Audit trail
- `product_images`: Product images

## 🛡️ Security Features

- JWT-based authentication
- Role-based access control
- Input validation and sanitization
- SQL injection protection
- XSS protection
- CSRF protection

## 🔧 Configuration

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/kibernum_ecommerce

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT Secret
JWT_SECRET_KEY=your-secret-key

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## 📝 Development

### Code Style
The project uses RuboCop for code style enforcement:
```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Database Migrations
```bash
# Create new migration
rails generate migration MigrationName

# Run migrations
rails db:migrate

# Rollback
rails db:rollback
```


## 📄 License

This project is part of a technical test for Kibernum.

## 🆘 Support

For questions or issues, please contact the development team or create an issue in the repository.
