-- =========================================
-- SQL BOOKSTORE PROJECT - ORACLE LIVE SQL VERSION
-- Schema Creation for Oracle Database
-- =========================================
-- This file creates the database schema optimized for Oracle Live SQL
-- Key differences from MySQL: SEQUENCES instead of AUTO_INCREMENT, 
-- CHECK constraints instead of ENUM, VARCHAR2 instead of VARCHAR

-- ===========================
-- 1. CREATE SEQUENCES (Oracle equivalent of AUTO_INCREMENT)
-- ===========================

-- Drop sequences if they exist (for re-running script)
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_author_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_publisher_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_category_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_book_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_customer_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_order_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_order_item_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_review_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_inventory_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create sequences
CREATE SEQUENCE seq_author_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_publisher_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_category_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_book_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_customer_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order_item_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_review_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_inventory_id START WITH 1 INCREMENT BY 1;

-- ===========================
-- 2. DROP EXISTING TABLES (for clean re-run)
-- ===========================

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE book_authors';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE reviews';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE inventory';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE order_items';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE orders';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE books';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE customers';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE categories';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE publishers';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE authors';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- ===========================
-- 3. CREATE TABLES
-- ===========================

-- Authors table
CREATE TABLE authors (
    author_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR2(100),
    biography CLOB,
    email VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id NUMBER PRIMARY KEY,
    publisher_name VARCHAR2(200) NOT NULL,
    address VARCHAR2(500),
    city VARCHAR2(100),
    state VARCHAR2(100),
    country VARCHAR2(100),
    postal_code VARCHAR2(20),
    phone VARCHAR2(20),
    email VARCHAR2(255),
    website VARCHAR2(255),
    founded_year NUMBER(4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table (with hierarchical support)
CREATE TABLE categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(100) NOT NULL UNIQUE,
    parent_category_id NUMBER,
    description CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_parent_category 
        FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Customers table
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(255) UNIQUE NOT NULL,
    phone VARCHAR2(20),
    date_of_birth DATE,
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    address VARCHAR2(500),
    city VARCHAR2(100),
    state VARCHAR2(100),
    country VARCHAR2(100),
    postal_code VARCHAR2(20),
    membership_level VARCHAR2(20) DEFAULT 'Bronze' 
        CHECK (membership_level IN ('Bronze', 'Silver', 'Gold', 'Platinum')),
    total_spent NUMBER(10,2) DEFAULT 0,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Books table
CREATE TABLE books (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(500) NOT NULL,
    author_id NUMBER NOT NULL,
    publisher_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    isbn_10 VARCHAR2(10) UNIQUE,
    isbn_13 VARCHAR2(13) UNIQUE,
    publication_date DATE,
    edition NUMBER DEFAULT 1,
    pages NUMBER,
    language VARCHAR2(50) DEFAULT 'English',
    format VARCHAR2(20) DEFAULT 'Paperback' 
        CHECK (format IN ('Hardcover', 'Paperback', 'eBook', 'Audiobook')),
    description CLOB,
    price NUMBER(10,2) NOT NULL CHECK (price > 0),
    cost_price NUMBER(10,2),
    weight_grams NUMBER,
    dimensions_cm VARCHAR2(50),
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0,1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_author FOREIGN KEY (author_id) REFERENCES authors(author_id),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id),
    CONSTRAINT fk_book_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Orders table
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR2(20) DEFAULT 'Pending' 
        CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    subtotal NUMBER(10,2) NOT NULL,
    tax_amount NUMBER(10,2) DEFAULT 0.00,
    shipping_cost NUMBER(10,2) DEFAULT 0.00,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(10,2) NOT NULL,
    payment_method VARCHAR2(20) 
        CHECK (payment_method IN ('Credit Card', 'Debit Card', 'PayPal', 'Cash', 'Bank Transfer')),
    payment_status VARCHAR2(20) DEFAULT 'Pending' 
        CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    shipping_address VARCHAR2(1000),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items table
CREATE TABLE order_items (
    order_item_id NUMBER PRIMARY KEY,
    order_id NUMBER NOT NULL,
    book_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    unit_price NUMBER(10,2) NOT NULL,
    total_price NUMBER(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_item_book FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Reviews table
CREATE TABLE reviews (
    review_id NUMBER PRIMARY KEY,
    book_id NUMBER NOT NULL,
    customer_id NUMBER NOT NULL,
    rating NUMBER(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_title VARCHAR2(255),
    review_text CLOB,
    is_verified_purchase NUMBER(1) DEFAULT 0 CHECK (is_verified_purchase IN (0,1)),
    helpful_votes NUMBER DEFAULT 0,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_book FOREIGN KEY (book_id) REFERENCES books(book_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT unique_customer_book_review UNIQUE (book_id, customer_id)
);

-- Inventory table
CREATE TABLE inventory (
    inventory_id NUMBER PRIMARY KEY,
    book_id NUMBER NOT NULL UNIQUE,
    quantity_in_stock NUMBER DEFAULT 0 CHECK (quantity_in_stock >= 0),
    reorder_level NUMBER DEFAULT 10,
    max_stock_level NUMBER DEFAULT 100,
    location VARCHAR2(100),
    last_restocked_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_book FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Book Authors table (many-to-many relationship)
CREATE TABLE book_authors (
    book_id NUMBER NOT NULL,
    author_id NUMBER NOT NULL,
    author_role VARCHAR2(50) DEFAULT 'Author' 
        CHECK (author_role IN ('Author', 'Co-Author', 'Editor', 'Translator', 'Illustrator')),
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) REFERENCES books(book_id),
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- ===========================
-- 4. CREATE TRIGGERS FOR AUTO-INCREMENT
-- ===========================

-- Authors trigger
CREATE OR REPLACE TRIGGER trg_authors_id
    BEFORE INSERT ON authors
    FOR EACH ROW
BEGIN
    :NEW.author_id := seq_author_id.NEXTVAL;
END;
/

-- Publishers trigger
CREATE OR REPLACE TRIGGER trg_publishers_id
    BEFORE INSERT ON publishers
    FOR EACH ROW
BEGIN
    :NEW.publisher_id := seq_publisher_id.NEXTVAL;
END;
/

-- Categories trigger
CREATE OR REPLACE TRIGGER trg_categories_id
    BEFORE INSERT ON categories
    FOR EACH ROW
BEGIN
    :NEW.category_id := seq_category_id.NEXTVAL;
END;
/

-- Books trigger
CREATE OR REPLACE TRIGGER trg_books_id
    BEFORE INSERT ON books
    FOR EACH ROW
BEGIN
    :NEW.book_id := seq_book_id.NEXTVAL;
END;
/

-- Customers trigger
CREATE OR REPLACE TRIGGER trg_customers_id
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    :NEW.customer_id := seq_customer_id.NEXTVAL;
END;
/

-- Orders trigger
CREATE OR REPLACE TRIGGER trg_orders_id
    BEFORE INSERT ON orders
    FOR EACH ROW
BEGIN
    :NEW.order_id := seq_order_id.NEXTVAL;
END;
/

-- Order Items trigger
CREATE OR REPLACE TRIGGER trg_order_items_id
    BEFORE INSERT ON order_items
    FOR EACH ROW
BEGIN
    :NEW.order_item_id := seq_order_item_id.NEXTVAL;
END;
/

-- Reviews trigger
CREATE OR REPLACE TRIGGER trg_reviews_id
    BEFORE INSERT ON reviews
    FOR EACH ROW
BEGIN
    :NEW.review_id := seq_review_id.NEXTVAL;
END;
/

-- Inventory trigger
CREATE OR REPLACE TRIGGER trg_inventory_id
    BEFORE INSERT ON inventory
    FOR EACH ROW
BEGIN
    :NEW.inventory_id := seq_inventory_id.NEXTVAL;
END;
/

-- ===========================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- ===========================

-- Primary search indexes
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_price ON books(price);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_books_author ON books(author_id);
CREATE INDEX idx_books_publisher ON books(publisher_id);
CREATE INDEX idx_books_isbn ON books(isbn_13);

-- Customer indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_membership ON customers(membership_level);
CREATE INDEX idx_customers_name ON customers(last_name, first_name);

-- Order indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);

-- Order items indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_book ON order_items(book_id);

-- Review indexes
CREATE INDEX idx_reviews_book ON reviews(book_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Inventory indexes
CREATE INDEX idx_inventory_book ON inventory(book_id);
CREATE INDEX idx_inventory_stock ON inventory(quantity_in_stock);

-- Author indexes
CREATE INDEX idx_authors_name ON authors(last_name, first_name);
CREATE INDEX idx_authors_nationality ON authors(nationality);

-- Publisher indexes
CREATE INDEX idx_publishers_name ON publishers(publisher_name);

-- ===========================
-- 6. UPDATE TRIGGERS FOR TIMESTAMPS
-- ===========================

-- Update timestamp triggers
CREATE OR REPLACE TRIGGER trg_authors_update
    BEFORE UPDATE ON authors
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_customers_update
    BEFORE UPDATE ON customers
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_books_update
    BEFORE UPDATE ON books
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_orders_update
    BEFORE UPDATE ON orders
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_inventory_update
    BEFORE UPDATE ON inventory
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- ===========================
-- 7. VERIFY SCHEMA CREATION
-- ===========================

-- Display created tables
SELECT table_name, 
       num_rows as "Rows",
       'Ready for data' as status
FROM user_tables 
WHERE table_name IN ('AUTHORS', 'PUBLISHERS', 'CATEGORIES', 'BOOKS', 
                     'CUSTOMERS', 'ORDERS', 'ORDER_ITEMS', 'REVIEWS', 
                     'INVENTORY', 'BOOK_AUTHORS')
ORDER BY table_name;

-- Display created sequences
SELECT sequence_name, 
       last_number as "Next Value",
       'Active' as status
FROM user_sequences
WHERE sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

-- Success message
SELECT 'Oracle Bookstore Schema Created Successfully!' as message,
       SYSDATE as created_date
FROM dual;
