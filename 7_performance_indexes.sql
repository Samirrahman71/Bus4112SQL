-- =========================================
-- SQL BOOKSTORE PROJECT - PERFORMANCE & INDEXES
-- =========================================
-- This file demonstrates database performance optimization techniques
-- Skills: Index creation, query optimization, performance analysis, execution plans

-- ===========================
-- 1. ANALYZE CURRENT PERFORMANCE
-- ===========================

-- Show current table sizes and row counts
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as size_mb,
    ROUND((data_length / 1024 / 1024), 2) as data_mb,
    ROUND((index_length / 1024 / 1024), 2) as index_mb
FROM information_schema.tables 
WHERE table_schema = DATABASE()
    AND table_type = 'BASE TABLE'
ORDER BY (data_length + index_length) DESC;

-- Show existing indexes
SELECT 
    table_name,
    index_name,
    GROUP_CONCAT(column_name ORDER BY seq_in_index) as columns,
    index_type,
    non_unique
FROM information_schema.statistics 
WHERE table_schema = DATABASE()
GROUP BY table_name, index_name
ORDER BY table_name, index_name;

-- ===========================
-- 2. PERFORMANCE-CRITICAL INDEXES
-- ===========================

-- Indexes for frequently searched columns
CREATE INDEX idx_books_title_fulltext ON books(title);
CREATE INDEX idx_books_publication_year ON books(YEAR(publication_date));
CREATE INDEX idx_books_active_price ON books(is_active, price);

-- Customer-related indexes for fast lookups
CREATE INDEX idx_customers_name_search ON customers(last_name, first_name);
CREATE INDEX idx_customers_email_active ON customers(email, is_active);
CREATE INDEX idx_customers_membership_registration ON customers(membership_level, registration_date);

-- Order processing indexes
CREATE INDEX idx_orders_status_customer ON orders(order_status, customer_id);
CREATE INDEX idx_orders_date_status ON orders(order_date DESC, order_status);
CREATE INDEX idx_order_items_order_book ON order_items(order_id, book_id);

-- Review and rating indexes
CREATE INDEX idx_reviews_book_verified ON reviews(book_id, is_verified_purchase);
CREATE INDEX idx_reviews_rating_date ON reviews(rating DESC, review_date DESC);
CREATE INDEX idx_reviews_customer_date ON reviews(customer_id, review_date DESC);

-- Inventory management indexes
CREATE INDEX idx_inventory_reorder_check ON inventory(quantity_in_stock, reorder_level);
CREATE INDEX idx_inventory_location ON inventory(location);
CREATE INDEX idx_inventory_last_restocked ON inventory(last_restocked_date);

-- Many-to-many relationship indexes
CREATE INDEX idx_book_authors_role ON book_authors(author_role, book_id);

-- ===========================
-- 3. COMPOSITE INDEXES FOR COMPLEX QUERIES
-- ===========================

-- For sales analysis queries
CREATE INDEX idx_orders_complete_analysis ON orders(order_status, order_date, customer_id, total_amount);

-- For book search and filtering
CREATE INDEX idx_books_search_filter ON books(category_id, price, publication_date, is_active);

-- For customer segmentation
CREATE INDEX idx_customers_segmentation ON customers(membership_level, total_spent, registration_date);

-- For inventory reporting
CREATE INDEX idx_inventory_status_analysis ON inventory(book_id, quantity_in_stock, reorder_level, last_restocked_date);

-- ===========================
-- 4. PARTIAL INDEXES (MySQL 8.0+)
-- ===========================

-- Index only active books
CREATE INDEX idx_active_books_price ON books(price, category_id) WHERE is_active = TRUE;

-- Index only delivered orders
CREATE INDEX idx_delivered_orders_revenue ON orders(order_date, total_amount) WHERE order_status = 'Delivered';

-- Index only verified reviews
CREATE INDEX idx_verified_reviews_rating ON reviews(book_id, rating) WHERE is_verified_purchase = TRUE;

-- ===========================
-- 5. QUERY OPTIMIZATION EXAMPLES
-- ===========================

-- Before optimization: Slow query example
-- EXPLAIN 
-- SELECT b.title, AVG(r.rating) as avg_rating
-- FROM books b
-- LEFT JOIN reviews r ON b.book_id = r.book_id
-- WHERE b.publication_date > '2000-01-01'
-- GROUP BY b.book_id;

-- After optimization: Using proper indexes
EXPLAIN FORMAT=JSON
SELECT 
    b.title, 
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count
FROM books b
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE b.publication_date > '2000-01-01'
    AND b.is_active = TRUE
GROUP BY b.book_id, b.title
HAVING review_count > 0
ORDER BY avg_rating DESC
LIMIT 20;

-- Complex query optimization
EXPLAIN FORMAT=JSON
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(r.rating) as avg_rating_given
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN reviews r ON c.customer_id = r.customer_id
WHERE o.order_status = 'Delivered'
    AND o.order_date >= '2024-01-01'
    AND c.membership_level IN ('Gold', 'Platinum')
GROUP BY c.customer_id
HAVING total_orders >= 2
ORDER BY total_spent DESC;

-- ===========================
-- 6. FULL-TEXT SEARCH INDEXES
-- ===========================

-- Full-text search for book titles and descriptions
ALTER TABLE books ADD FULLTEXT(title, description);

-- Full-text search for author names
ALTER TABLE authors ADD FULLTEXT(first_name, last_name, biography);

-- Full-text search for reviews
ALTER TABLE reviews ADD FULLTEXT(review_title, review_text);

-- Example full-text searches
SELECT 
    book_id,
    title,
    MATCH(title, description) AGAINST('harry potter wizard' IN NATURAL LANGUAGE MODE) as relevance_score
FROM books
WHERE MATCH(title, description) AGAINST('harry potter wizard' IN NATURAL LANGUAGE MODE)
ORDER BY relevance_score DESC;

-- Boolean full-text search
SELECT 
    book_id,
    title,
    description
FROM books
WHERE MATCH(title, description) AGAINST('+fantasy -horror' IN BOOLEAN MODE);

-- ===========================
-- 7. QUERY PERFORMANCE MONITORING
-- ===========================

-- Create a performance monitoring table
CREATE TABLE query_performance_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    query_type VARCHAR(100),
    execution_time_ms INT,
    rows_examined INT,
    rows_returned INT,
    query_text TEXT,
    execution_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_perf_log_date (execution_date),
    INDEX idx_perf_log_type (query_type, execution_time_ms)
);

-- Procedure to log slow queries
DELIMITER //
CREATE PROCEDURE sp_log_query_performance(
    IN p_query_type VARCHAR(100),
    IN p_execution_time INT,
    IN p_rows_examined INT,
    IN p_rows_returned INT,
    IN p_query_text TEXT
)
BEGIN
    INSERT INTO query_performance_log 
        (query_type, execution_time_ms, rows_examined, rows_returned, query_text)
    VALUES 
        (p_query_type, p_execution_time, p_rows_examined, p_rows_returned, p_query_text);
END //
DELIMITER ;

-- ===========================
-- 8. INDEX MAINTENANCE QUERIES
-- ===========================

-- Check index usage statistics
SELECT 
    s.table_name,
    s.index_name,
    s.cardinality,
    ROUND(((s.cardinality / t.table_rows) * 100), 2) as selectivity_percent
FROM information_schema.statistics s
JOIN information_schema.tables t ON s.table_name = t.table_name
WHERE s.table_schema = DATABASE()
    AND t.table_schema = DATABASE()
    AND s.cardinality > 0
ORDER BY selectivity_percent DESC;

-- Find duplicate indexes
SELECT 
    table_name,
    GROUP_CONCAT(index_name) as duplicate_indexes,
    GROUP_CONCAT(column_name ORDER BY seq_in_index) as columns
FROM information_schema.statistics 
WHERE table_schema = DATABASE()
GROUP BY table_name, GROUP_CONCAT(column_name ORDER BY seq_in_index)
HAVING COUNT(*) > 1;

-- Analyze table fragmentation
SHOW TABLE STATUS WHERE Name IN (
    'books', 'customers', 'orders', 'order_items', 'reviews', 'inventory'
);

-- ===========================
-- 9. PARTITIONING EXAMPLES
-- ===========================

-- Example: Partition orders table by year (for large datasets)
-- Note: This would require recreating the table

/*
CREATE TABLE orders_partitioned (
    order_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Cash', 'Bank Transfer'),
    PRIMARY KEY (order_id, order_date),
    INDEX idx_customer (customer_id),
    INDEX idx_status (order_status)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

-- ===========================
-- 10. PERFORMANCE TESTING QUERIES
-- ===========================

-- Test query performance with different approaches

-- Method 1: Using subquery
SET @start_time = NOW(6);
SELECT 
    b.title,
    (SELECT AVG(rating) FROM reviews r WHERE r.book_id = b.book_id) as avg_rating
FROM books b
WHERE b.price > 15;
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as subquery_microseconds;

-- Method 2: Using JOIN
SET @start_time = NOW(6);
SELECT 
    b.title,
    AVG(r.rating) as avg_rating
FROM books b
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE b.price > 15
GROUP BY b.book_id, b.title;
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as join_microseconds;

-- Performance comparison for different WHERE clause orders
-- Test with selective condition first
EXPLAIN
SELECT * FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE b.price > 20
    AND a.nationality = 'American';

-- Test with less selective condition first
EXPLAIN
SELECT * FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE a.nationality = 'American'
    AND b.price > 20;

-- ===========================
-- 11. INDEX RECOMMENDATIONS
-- ===========================

-- Procedure to generate index recommendations
DELIMITER //
CREATE PROCEDURE sp_index_recommendations()
BEGIN
    SELECT 'Missing Index Recommendations' as recommendation_type;
    
    -- Find queries that might benefit from indexes
    SELECT 
        'Consider index on books(category_id, price)' as recommendation,
        'For category-based price filtering queries' as reason
    
    UNION ALL
    
    SELECT 
        'Consider index on orders(customer_id, order_date DESC)' as recommendation,
        'For customer order history queries' as reason
    
    UNION ALL
    
    SELECT 
        'Consider composite index on reviews(book_id, rating, is_verified_purchase)' as recommendation,
        'For book rating analysis queries' as reason;
END //
DELIMITER ;

-- Run index recommendations
CALL sp_index_recommendations();

-- ===========================
-- 12. CLEANUP AND MAINTENANCE
-- ===========================

-- Analyze tables for optimal performance
ANALYZE TABLE books, authors, customers, orders, order_items, reviews, inventory;

-- Optimize tables (defragment)
-- OPTIMIZE TABLE books, authors, customers, orders, order_items, reviews, inventory;

-- Check table integrity
-- CHECK TABLE books, authors, customers, orders, order_items, reviews, inventory;

-- Show final index summary
SELECT 
    table_name,
    COUNT(*) as index_count,
    GROUP_CONCAT(DISTINCT index_name) as indexes
FROM information_schema.statistics 
WHERE table_schema = DATABASE()
    AND index_name != 'PRIMARY'
GROUP BY table_name
ORDER BY index_count DESC;

-- Performance summary
SELECT 
    'Performance Optimization Complete' as status,
    COUNT(DISTINCT table_name) as tables_optimized,
    COUNT(*) as total_indexes_created
FROM information_schema.statistics 
WHERE table_schema = DATABASE();
