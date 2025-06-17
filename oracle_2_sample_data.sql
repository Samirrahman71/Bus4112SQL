-- =========================================
-- SQL BOOKSTORE PROJECT - ORACLE LIVE SQL VERSION
-- Sample Data Insertion for Oracle Database
-- =========================================
-- This file inserts sample data optimized for Oracle Live SQL
-- Run this AFTER oracle_1_schema_creation.sql

-- ===========================
-- 1. INSERT AUTHORS
-- ===========================

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('George', 'Orwell', DATE '1903-06-25', 'British', 'Eric Arthur Blair, known by his pen name George Orwell, was an English novelist and essayist.', 'george.orwell@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('Harper', 'Lee', DATE '1926-04-28', 'American', 'Harper Lee was an American novelist widely known for To Kill a Mockingbird.', 'harper.lee@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('F. Scott', 'Fitzgerald', DATE '1896-09-24', 'American', 'Francis Scott Key Fitzgerald was an American novelist and short story writer.', 'scott.fitzgerald@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('Jane', 'Austen', DATE '1775-12-16', 'British', 'Jane Austen was an English novelist known for her social commentary and wit.', 'jane.austen@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('J.K.', 'Rowling', DATE '1965-07-31', 'British', 'Joanne Rowling is a British author, best known for the Harry Potter series.', 'jk.rowling@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('Stephen', 'King', DATE '1947-09-21', 'American', 'Stephen Edwin King is an American author of horror, supernatural fiction, suspense, and fantasy novels.', 'stephen.king@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('Agatha', 'Christie', DATE '1890-09-15', 'British', 'Dame Agatha Mary Clarissa Christie was an English writer known for her detective novels.', 'agatha.christie@email.com');

INSERT INTO authors (first_name, last_name, date_of_birth, nationality, biography, email) VALUES
('Dan', 'Brown', DATE '1964-06-22', 'American', 'Daniel Gerhard Brown is an American author best known for his thriller novels.', 'dan.brown@email.com');

-- ===========================
-- 2. INSERT PUBLISHERS
-- ===========================

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('Penguin Random House', '1745 Broadway', 'New York', 'NY', 'USA', '10019', '+1-212-751-2600', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com', 1935);

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('HarperCollins', '195 Broadway', 'New York', 'NY', 'USA', '10007', '+1-212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com', 1989);

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('Simon & Schuster', '1230 Avenue of the Americas', 'New York', 'NY', 'USA', '10020', '+1-212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com', 1924);

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('Macmillan Publishers', '120 Broadway', 'New York', 'NY', 'USA', '10271', '+1-646-307-5151', 'info@macmillan.com', 'www.macmillan.com', 1843);

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('Scholastic Corporation', '557 Broadway', 'New York', 'NY', 'USA', '10012', '+1-212-343-6100', 'info@scholastic.com', 'www.scholastic.com', 1920);

INSERT INTO publishers (publisher_name, address, city, state, country, postal_code, phone, email, website, founded_year) VALUES
('Oxford University Press', 'Great Clarendon Street', 'Oxford', 'Oxfordshire', 'UK', 'OX2 6DP', '+44-1865-556767', 'enquiry@oup.com', 'www.oup.com', 1586);

-- ===========================
-- 3. INSERT CATEGORIES
-- ===========================

INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Imaginative literature including novels and short stories');

INSERT INTO categories (category_name, description) VALUES
('Non-Fiction', 'Factual books including biographies, history, and self-help');

INSERT INTO categories (category_name, description) VALUES
('Mystery', 'Books involving puzzles, crimes, and detective work');

INSERT INTO categories (category_name, description) VALUES
('Science Fiction', 'Literature that deals with futuristic concepts and advanced science');

INSERT INTO categories (category_name, description) VALUES
('Fantasy', 'Literature featuring magical or supernatural elements');

INSERT INTO categories (category_name, description) VALUES
('Romance', 'Literature focused on love stories and relationships');

INSERT INTO categories (category_name, description) VALUES
('Thriller', 'Fast-paced books designed to create suspense and excitement');

INSERT INTO categories (category_name, description) VALUES
('Biography', 'Life stories of notable individuals');

-- Add subcategories
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Historical Fiction', 1, 'Fiction set in the past');

INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Contemporary Fiction', 1, 'Fiction set in the present day');

-- ===========================
-- 4. INSERT CUSTOMERS
-- ===========================

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('John', 'Smith', 'john.smith@email.com', '+1-555-0101', DATE '1985-03-15', 'Male', '123 Main St', 'New York', 'NY', 'USA', '10001', 'Gold');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0102', DATE '1990-07-22', 'Female', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90210', 'Silver');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Michael', 'Brown', 'michael.brown@email.com', '+1-555-0103', DATE '1978-11-08', 'Male', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60601', 'Platinum');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Emily', 'Davis', 'emily.davis@email.com', '+1-555-0104', DATE '1995-04-12', 'Female', '321 Elm St', 'Houston', 'TX', 'USA', '77001', 'Bronze');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('David', 'Wilson', 'david.wilson@email.com', '+1-555-0105', DATE '1982-09-30', 'Male', '654 Maple Dr', 'Phoenix', 'AZ', 'USA', '85001', 'Silver');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Jennifer', 'Martinez', 'jennifer.martinez@email.com', '+1-555-0106', DATE '1988-01-18', 'Female', '987 Cedar Ln', 'Philadelphia', 'PA', 'USA', '19101', 'Gold');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Robert', 'Anderson', 'robert.anderson@email.com', '+1-555-0107', DATE '1975-12-05', 'Male', '147 Birch St', 'San Antonio', 'TX', 'USA', '78201', 'Bronze');

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, membership_level) VALUES
('Lisa', 'Taylor', 'lisa.taylor@email.com', '+1-555-0108', DATE '1992-06-25', 'Female', '258 Spruce Ave', 'San Diego', 'CA', 'USA', '92101', 'Platinum');

-- ===========================
-- 5. INSERT BOOKS
-- ===========================

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('1984', 1, 1, 1, '9780451524935', DATE '1949-06-08', 328, 15.99, 8.50, 'A dystopian social science fiction novel about totalitarian rule.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('Animal Farm', 1, 1, 1, '9780451526342', DATE '1945-08-17', 112, 12.99, 7.25, 'An allegorical novella about farm animals who rebel against their human farmer.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('To Kill a Mockingbird', 2, 2, 1, '9780061120084', DATE '1960-07-11', 384, 14.99, 8.00, 'A novel about the serious issues of rape and racial inequality.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('The Great Gatsby', 3, 3, 1, '9780743273565', DATE '1925-04-10', 180, 13.99, 7.50, 'A classic American novel set in the Jazz Age.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('Pride and Prejudice', 4, 1, 6, '9780141439518', DATE '1813-01-28', 432, 11.99, 6.75, 'A romantic novel about manners, upbringing, morality, and marriage.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('Harry Potter and the Philosopher''s Stone', 5, 5, 5, '9780747532699', DATE '1997-06-26', 223, 19.99, 12.00, 'The first novel in the Harry Potter series.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('The Shining', 6, 2, 7, '9780307743657', DATE '1977-01-28', 447, 16.99, 9.50, 'A horror novel about a family isolated in a haunted hotel.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('Murder on the Orient Express', 7, 2, 3, '9780062693662', DATE '1934-01-01', 256, 14.99, 8.25, 'A detective novel featuring Hercule Poirot.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('The Da Vinci Code', 8, 2, 7, '9780307474278', DATE '2003-03-18', 454, 17.99, 10.50, 'A mystery thriller novel involving secret religious history.');

INSERT INTO books (title, author_id, publisher_id, category_id, isbn_13, publication_date, pages, price, cost_price, description) VALUES
('Angels and Demons', 8, 2, 7, '9780671027360', DATE '2000-05-01', 616, 16.99, 9.75, 'A mystery thriller novel about ancient secrets and modern science.');

-- ===========================
-- 6. INSERT INVENTORY
-- ===========================

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(1, 50, 10, 'Warehouse A-1');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(2, 25, 5, 'Warehouse A-2');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(3, 40, 8, 'Warehouse B-1');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(4, 30, 6, 'Warehouse B-2');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(5, 35, 7, 'Warehouse C-1');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(6, 75, 15, 'Warehouse C-2');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(7, 20, 5, 'Warehouse D-1');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(8, 45, 9, 'Warehouse D-2');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(9, 60, 12, 'Warehouse E-1');

INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, location) VALUES
(10, 55, 11, 'Warehouse E-2');

-- ===========================
-- 7. INSERT ORDERS
-- ===========================

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(1, TIMESTAMP '2024-01-15 10:30:00', 'Delivered', 45.97, 3.68, 5.99, 55.64, 'Credit Card', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(2, TIMESTAMP '2024-01-18 14:22:00', 'Delivered', 28.98, 2.32, 0.00, 31.30, 'PayPal', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(3, TIMESTAMP '2024-01-22 09:15:00', 'Shipped', 34.98, 2.80, 5.99, 43.77, 'Credit Card', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(4, TIMESTAMP '2024-01-25 16:45:00', 'Processing', 19.99, 1.60, 5.99, 27.58, 'Debit Card', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(5, TIMESTAMP '2024-01-28 11:20:00', 'Delivered', 33.98, 2.72, 0.00, 36.70, 'Credit Card', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(1, TIMESTAMP '2024-02-02 13:10:00', 'Delivered', 16.99, 1.36, 5.99, 24.34, 'Credit Card', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(6, TIMESTAMP '2024-02-05 15:35:00', 'Delivered', 29.98, 2.40, 5.99, 38.37, 'PayPal', 'Paid');

INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, payment_status) VALUES
(7, TIMESTAMP '2024-02-10 08:50:00', 'Cancelled', 14.99, 1.20, 5.99, 22.18, 'Credit Card', 'Refunded');

-- ===========================
-- 8. INSERT ORDER ITEMS
-- ===========================

-- Order 1 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(1, 1, 1, 15.99, 15.99);

INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(1, 3, 2, 14.99, 29.98);

-- Order 2 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(2, 2, 1, 12.99, 12.99);

INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(2, 1, 1, 15.99, 15.99);

-- Order 3 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(3, 6, 1, 19.99, 19.99);

INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(3, 3, 1, 14.99, 14.99);

-- Order 4 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(4, 6, 1, 19.99, 19.99);

-- Order 5 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(5, 9, 2, 16.99, 33.98);

-- Order 6 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(6, 7, 1, 16.99, 16.99);

-- Order 7 items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(7, 8, 2, 14.99, 29.98);

-- Order 8 items (cancelled order)
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
(8, 3, 1, 14.99, 14.99);

-- ===========================
-- 9. INSERT REVIEWS
-- ===========================

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(1, 1, 5.0, 'A masterpiece of dystopian literature', 'Orwell''s vision of a totalitarian future is both terrifying and compelling. A must-read for everyone.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(3, 1, 4.5, 'Timeless classic', 'Harper Lee''s exploration of racial injustice is as relevant today as it was when first published.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(2, 2, 4.0, 'Clever allegory', 'A brilliant satire of the Russian Revolution told through the eyes of farm animals.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(1, 2, 5.0, 'Prophetic and haunting', 'The concepts of Big Brother and thoughtcrime are more relevant than ever in our digital age.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(6, 3, 4.5, 'Magical beginning', 'The start of an incredible journey. Rowling''s world-building is exceptional.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(3, 3, 4.0, 'Important social commentary', 'A powerful story about justice, morality, and human nature.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(6, 4, 5.0, 'Pure magic', 'This book ignited my love for reading. The characters feel real and the magic is believable.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(9, 5, 3.5, 'Entertaining thriller', 'Fast-paced and exciting, though some plot points are a bit far-fetched.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(7, 6, 4.0, 'Genuinely scary', 'Stephen King at his best. The psychological horror is more effective than any gore.', 1);

INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase) VALUES
(8, 7, 4.5, 'Classic mystery', 'Agatha Christie''s plotting is superb. The solution is both surprising and logical.', 1);

-- ===========================
-- 10. INSERT BOOK_AUTHORS (Many-to-many relationships)
-- ===========================

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(1, 1, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(2, 1, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(3, 2, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(4, 3, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(5, 4, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(6, 5, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(7, 6, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(8, 7, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(9, 8, 'Author');

INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(10, 8, 'Author');

-- ===========================
-- 11. UPDATE CUSTOMER TOTAL_SPENT BASED ON DELIVERED ORDERS
-- ===========================

-- Update customer total spent for delivered orders
UPDATE customers 
SET total_spent = (
    SELECT NVL(SUM(o.total_amount), 0)
    FROM orders o
    WHERE o.customer_id = customers.customer_id
    AND o.order_status IN ('Delivered', 'Shipped')
);

-- ===========================
-- 12. COMMIT TRANSACTION
-- ===========================

COMMIT;

-- ===========================
-- 13. VERIFY DATA INSERTION
-- ===========================

-- Display table row counts
SELECT 'AUTHORS' as table_name, COUNT(*) as row_count FROM authors
UNION ALL
SELECT 'PUBLISHERS', COUNT(*) FROM publishers
UNION ALL
SELECT 'CATEGORIES', COUNT(*) FROM categories
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM customers
UNION ALL
SELECT 'BOOKS', COUNT(*) FROM books
UNION ALL
SELECT 'INVENTORY', COUNT(*) FROM inventory
UNION ALL
SELECT 'ORDERS', COUNT(*) FROM orders
UNION ALL
SELECT 'ORDER_ITEMS', COUNT(*) FROM order_items
UNION ALL
SELECT 'REVIEWS', COUNT(*) FROM reviews
UNION ALL
SELECT 'BOOK_AUTHORS', COUNT(*) FROM book_authors
ORDER BY table_name;

-- Show sample data
SELECT 'Sample Books Data' as info FROM dual;

SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    p.publisher_name,
    c.category_name,
    b.price
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
WHERE ROWNUM <= 5
ORDER BY b.title;

-- Show sample orders
SELECT 'Sample Orders Data' as info FROM dual;

SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    o.order_date,
    o.order_status,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE ROWNUM <= 5
ORDER BY o.order_date DESC;

-- Success message
SELECT 
    'Oracle Bookstore Sample Data Loaded Successfully!' as message,
    SYSDATE as loaded_date
FROM dual;
