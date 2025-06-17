-- =========================================
-- SQL BOOKSTORE PROJECT - SCHEMA CREATION
-- =========================================
-- This file creates the complete database schema for a bookstore system
-- Demonstrates: Table creation, constraints, relationships, data types

-- Create database (MySQL/PostgreSQL syntax)
-- CREATE DATABASE bookstore_db;
-- USE bookstore_db;

-- ===========================
-- 1. AUTHORS TABLE
-- ===========================
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ===========================
-- 2. PUBLISHERS TABLE
-- ===========================
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(200),
    city VARCHAR(50),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    founded_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- 3. CATEGORIES TABLE
-- ===========================
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- ===========================
-- 4. BOOKS TABLE (Main catalog)
-- ===========================
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    author_id INT NOT NULL,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    publication_date DATE,
    page_count INT,
    language VARCHAR(30) DEFAULT 'English',
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    description TEXT,
    cover_image_url VARCHAR(200),
    weight_kg DECIMAL(5,2),
    dimensions VARCHAR(50), -- "Length x Width x Height"
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    
    -- Constraints
    CONSTRAINT chk_price_positive CHECK (price > 0),
    CONSTRAINT chk_pages_positive CHECK (page_count > 0),
    CONSTRAINT chk_cost_reasonable CHECK (cost <= price)
);

-- ===========================
-- 5. CUSTOMERS TABLE
-- ===========================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say'),
    membership_level ENUM('Bronze', 'Silver', 'Gold', 'Platinum') DEFAULT 'Bronze',
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Address information
    address_line1 VARCHAR(100),
    address_line2 VARCHAR(100),
    city VARCHAR(50),
    state_province VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%'),
    CONSTRAINT chk_total_spent_positive CHECK (total_spent >= 0)
);

-- ===========================
-- 6. ORDERS TABLE
-- ===========================
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    
    -- Pricing information
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Shipping information
    shipping_address_line1 VARCHAR(100),
    shipping_address_line2 VARCHAR(100),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(50),
    
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Cash', 'Bank Transfer'),
    notes TEXT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    
    CONSTRAINT chk_totals_positive CHECK (subtotal > 0 AND total_amount > 0),
    CONSTRAINT chk_shipping_logic CHECK (shipped_date IS NULL OR shipped_date >= order_date),
    CONSTRAINT chk_delivery_logic CHECK (delivered_date IS NULL OR delivered_date >= shipped_date)
);

-- ===========================
-- 7. ORDER_ITEMS TABLE
-- ===========================
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) DEFAULT 0.00,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_unit_price_positive CHECK (unit_price > 0),
    CONSTRAINT chk_total_calculation CHECK (total_price = (unit_price * quantity) - discount_applied)
);

-- ===========================
-- 8. INVENTORY TABLE
-- ===========================
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL UNIQUE,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 10,
    max_stock_level INT DEFAULT 100,
    last_restocked_date DATE,
    location VARCHAR(50), -- Warehouse location/shelf
    
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    
    CONSTRAINT chk_stock_levels CHECK (quantity_in_stock >= 0 AND reorder_level >= 0),
    CONSTRAINT chk_max_stock CHECK (max_stock_level > reorder_level)
);

-- ===========================
-- 9. REVIEWS TABLE
-- ===========================
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_title VARCHAR(100),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    
    CONSTRAINT chk_rating_range CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_helpful_votes CHECK (helpful_votes >= 0),
    
    -- Unique constraint: one review per customer per book
    UNIQUE KEY unique_customer_book_review (customer_id, book_id)
);

-- ===========================
-- 10. BOOK_AUTHORS TABLE (Many-to-Many)
-- ===========================
-- For books with multiple authors
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role ENUM('Primary Author', 'Co-Author', 'Editor', 'Translator') DEFAULT 'Primary Author',
    
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- ===========================
-- INDEXES FOR PERFORMANCE
-- ===========================
-- These will be covered in detail in the performance file

-- Books table indexes
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_price ON books(price);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_books_publication_date ON books(publication_date);

-- Customers table indexes  
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_name ON customers(last_name, first_name);
CREATE INDEX idx_customers_membership ON customers(membership_level);

-- Orders table indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);

-- Reviews table indexes
CREATE INDEX idx_reviews_book ON reviews(book_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_date ON reviews(review_date);

SHOW TABLES;
