-- =========================================
-- SQL BOOKSTORE PROJECT - BASIC QUERIES
-- =========================================
-- This file demonstrates basic SQL operations and data retrieval
-- Skills: SELECT, WHERE, ORDER BY, LIMIT, basic functions, filtering

-- ===========================
-- 1. BASIC SELECT OPERATIONS
-- ===========================

-- Show all books with basic information
SELECT title, price, publication_date 
FROM books 
ORDER BY title;

-- Count total number of books
SELECT COUNT(*) as total_books FROM books;

-- Show unique publishers
SELECT DISTINCT publisher_name 
FROM publishers 
ORDER BY publisher_name;

-- ===========================
-- 2. FILTERING WITH WHERE
-- ===========================

-- Books priced under $15
SELECT title, author_id, price 
FROM books 
WHERE price < 15.00
ORDER BY price;

-- Books published after 1980
SELECT title, publication_date, price
FROM books 
WHERE publication_date > '1980-01-01'
ORDER BY publication_date DESC;

-- Horror books specifically
SELECT b.title, b.price, c.category_name
FROM books b
JOIN categories c ON b.category_id = c.category_id
WHERE c.category_name = 'Horror';

-- Books with 'Harry Potter' in the title
SELECT title, publication_date, price
FROM books
WHERE title LIKE '%Harry Potter%'
ORDER BY publication_date;

-- ===========================
-- 3. SORTING AND LIMITING
-- ===========================

-- Top 5 most expensive books
SELECT title, price, publication_date
FROM books
ORDER BY price DESC
LIMIT 5;

-- 5 most recent books
SELECT title, publication_date, price
FROM books
ORDER BY publication_date DESC
LIMIT 5;

-- Oldest books in the database
SELECT title, publication_date, price
FROM books
WHERE publication_date IS NOT NULL
ORDER BY publication_date ASC
LIMIT 3;

-- ===========================
-- 4. BASIC AGGREGATIONS
-- ===========================

-- Average book price
SELECT ROUND(AVG(price), 2) as average_price
FROM books;

-- Price range of books
SELECT 
    MIN(price) as cheapest_book,
    MAX(price) as most_expensive_book,
    ROUND(AVG(price), 2) as average_price,
    COUNT(*) as total_books
FROM books;

-- Count books by category
SELECT 
    c.category_name,
    COUNT(b.book_id) as book_count
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY book_count DESC;

-- ===========================
-- 5. DATE FUNCTIONS
-- ===========================

-- Books published in specific decades
SELECT 
    FLOOR(YEAR(publication_date)/10)*10 as decade,
    COUNT(*) as books_published
FROM books
WHERE publication_date IS NOT NULL
GROUP BY decade
ORDER BY decade;

-- Current age of books (years since publication)
SELECT 
    title,
    publication_date,
    YEAR(CURDATE()) - YEAR(publication_date) as years_old
FROM books
WHERE publication_date IS NOT NULL
ORDER BY years_old DESC;

-- ===========================
-- 6. STRING FUNCTIONS
-- ===========================

-- Author names in different formats
SELECT 
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) as full_name,
    CONCAT(last_name, ', ', first_name) as last_first,
    UPPER(CONCAT(first_name, ' ', last_name)) as full_name_upper
FROM authors
ORDER BY last_name;

-- Book titles with length
SELECT 
    title,
    LENGTH(title) as title_length,
    LEFT(title, 20) as title_short
FROM books
ORDER BY title_length DESC;

-- ===========================
-- 7. CONDITIONAL LOGIC
-- ===========================

-- Categorize books by price range
SELECT 
    title,
    price,
    CASE 
        WHEN price < 10 THEN 'Budget'
        WHEN price BETWEEN 10 AND 15 THEN 'Mid-range'
        WHEN price > 15 THEN 'Premium'
        ELSE 'Unknown'
    END as price_category
FROM books
ORDER BY price;

-- Customer membership status
SELECT 
    CONCAT(first_name, ' ', last_name) as customer_name,
    membership_level,
    total_spent,
    CASE 
        WHEN total_spent > 100 THEN 'High Value'
        WHEN total_spent > 50 THEN 'Medium Value'
        ELSE 'New Customer'
    END as customer_value
FROM customers
ORDER BY total_spent DESC;

-- ===========================
-- 8. BASIC SUBQUERIES
-- ===========================

-- Books more expensive than average
SELECT title, price
FROM books
WHERE price > (SELECT AVG(price) FROM books)
ORDER BY price DESC;

-- Authors who have written books
SELECT first_name, last_name
FROM authors
WHERE author_id IN (SELECT DISTINCT author_id FROM books)
ORDER BY last_name;

-- Customers who have placed orders
SELECT first_name, last_name, email
FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders)
ORDER BY last_name;

-- ===========================
-- 9. NULL HANDLING
-- ===========================

-- Books with missing publication dates
SELECT title, publication_date, price
FROM books
WHERE publication_date IS NULL;

-- Authors with complete information
SELECT 
    CONCAT(first_name, ' ', last_name) as author_name,
    birth_date,
    nationality
FROM authors
WHERE birth_date IS NOT NULL 
    AND nationality IS NOT NULL
ORDER BY last_name;

-- Handle missing data with COALESCE
SELECT 
    title,
    COALESCE(description, 'No description available') as book_description
FROM books
LIMIT 5;

-- ===========================
-- 10. BASIC JOINS
-- ===========================

-- Books with their authors
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    b.price
FROM books b
JOIN authors a ON b.author_id = a.author_id
ORDER BY b.title;

-- Books with categories
SELECT 
    b.title,
    c.category_name,
    b.price
FROM books b
JOIN categories c ON b.category_id = c.category_id
ORDER BY c.category_name, b.title;

-- Books with publishers
SELECT 
    b.title,
    p.publisher_name,
    b.publication_date
FROM books b
JOIN publishers p ON b.publisher_id = p.publisher_id
ORDER BY p.publisher_name, b.title;

-- Complete book information
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    p.publisher_name,
    c.category_name,
    b.price,
    b.publication_date
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
ORDER BY b.title;

-- ===========================
-- SUMMARY STATISTICS
-- ===========================

-- Database overview
SELECT 
    'Books' as table_name, COUNT(*) as record_count FROM books
UNION ALL
SELECT 'Authors', COUNT(*) FROM authors
UNION ALL
SELECT 'Publishers', COUNT(*) FROM publishers
UNION ALL
SELECT 'Customers', COUNT(*) FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews;
