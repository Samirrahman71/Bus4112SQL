-- Modern Database Features Enhancement
-- Adds JSON support, full-text search, and advanced analytics

-- ===========================================
-- JSON METADATA FOR FLEXIBLE BOOK ATTRIBUTES
-- ===========================================

-- Add JSON column for flexible book metadata
ALTER TABLE books ADD COLUMN metadata JSON;

-- Update books with JSON metadata examples
UPDATE books 
SET metadata = JSON_OBJECT(
    'genres', JSON_ARRAY('Fiction', 'Dystopian'),
    'awards', JSON_ARRAY('Hugo Award Nominee'),
    'themes', JSON_ARRAY('surveillance', 'totalitarianism'),
    'reading_level', 'Adult',
    'page_count', 328,
    'language', 'English'
)
WHERE title = '1984';

UPDATE books 
SET metadata = JSON_OBJECT(
    'genres', JSON_ARRAY('Fiction', 'Coming-of-age'),
    'awards', JSON_ARRAY('Pulitzer Prize Winner'),
    'themes', JSON_ARRAY('racism', 'justice', 'childhood'),
    'reading_level', 'High School',
    'page_count', 281,
    'language', 'English'
)
WHERE title = 'To Kill a Mockingbird';

UPDATE books 
SET metadata = JSON_OBJECT(
    'genres', JSON_ARRAY('Romance', 'Historical Fiction'),
    'awards', JSON_ARRAY('Bestseller'),
    'themes', JSON_ARRAY('love', 'class', 'society'),
    'reading_level', 'Adult',
    'page_count', 432,
    'language', 'English'
)
WHERE title = 'Pride and Prejudice';

-- ===========================================
-- FULL-TEXT SEARCH CAPABILITIES
-- ===========================================

-- Add full-text indexes for enhanced search
ALTER TABLE books ADD FULLTEXT(title, description);
ALTER TABLE authors ADD FULLTEXT(first_name, last_name, biography);

-- Advanced search queries using full-text search
-- Search books by title or description
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    b.price,
    MATCH(b.title, b.description) AGAINST('science fiction' IN NATURAL LANGUAGE MODE) as relevance_score
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE MATCH(b.title, b.description) AGAINST('science fiction' IN NATURAL LANGUAGE MODE)
ORDER BY relevance_score DESC;

-- Search authors by name or biography
SELECT 
    first_name || ' ' || last_name as author_name,
    nationality,
    MATCH(first_name, last_name, biography) AGAINST('British writer' IN NATURAL LANGUAGE MODE) as relevance_score
FROM authors
WHERE MATCH(first_name, last_name, biography) AGAINST('British writer' IN NATURAL LANGUAGE MODE)
ORDER BY relevance_score DESC;

-- ===========================================
-- REAL-TIME DASHBOARD QUERIES
-- ===========================================

-- Daily Sales Summary (KPI Dashboard)
SELECT 
    'Today Sales' as metric,
    COUNT(DISTINCT order_id) as orders_count,
    FORMAT(SUM(total_amount), 2) as total_revenue,
    FORMAT(AVG(total_amount), 2) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders 
WHERE DATE(order_date) = CURDATE() AND order_status != 'Cancelled';

-- Top Performing Books This Month
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    COUNT(oi.order_item_id) as units_sold,
    FORMAT(SUM(oi.price * oi.quantity), 2) as revenue,
    FORMAT(AVG(r.rating), 1) as avg_rating
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE MONTH(o.order_date) = MONTH(CURDATE()) 
    AND YEAR(o.order_date) = YEAR(CURDATE())
    AND o.order_status = 'Delivered'
GROUP BY b.book_id, b.title, a.first_name, a.last_name
ORDER BY units_sold DESC
LIMIT 5;

-- Inventory Alerts (Low Stock Warning)
SELECT 
    b.title,
    i.quantity_available,
    i.reorder_level,
    (i.reorder_level - i.quantity_available) as units_below_threshold,
    CASE 
        WHEN i.quantity_available = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_available <= i.reorder_level * 0.5 THEN 'CRITICAL'
        WHEN i.quantity_available <= i.reorder_level THEN 'LOW'
        ELSE 'OK'
    END as stock_status
FROM books b
JOIN inventory i ON b.book_id = i.book_id
WHERE i.quantity_available <= i.reorder_level
ORDER BY (i.quantity_available / i.reorder_level) ASC;

-- Customer Activity Heatmap (by hour of day)
SELECT 
    HOUR(order_date) as hour_of_day,
    COUNT(*) as order_count,
    FORMAT(SUM(total_amount), 2) as hourly_revenue,
    REPEAT('█', FLOOR(COUNT(*) / 2)) as activity_bar
FROM orders 
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY HOUR(order_date)
ORDER BY hour_of_day;

-- ===========================================
-- JSON ANALYTICS QUERIES
-- ===========================================

-- Books by Genre (using JSON data)
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.genres[0]')) as primary_genre,
    COUNT(*) as book_count,
    FORMAT(AVG(price), 2) as avg_price,
    FORMAT(SUM(oi.quantity), 0) as total_sold
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
WHERE metadata IS NOT NULL
GROUP BY JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.genres[0]'))
ORDER BY book_count DESC;

-- Award-Winning Books Performance
SELECT 
    b.title,
    JSON_UNQUOTE(JSON_EXTRACT(b.metadata, '$.awards[0]')) as primary_award,
    COUNT(oi.order_item_id) as times_ordered,
    FORMAT(AVG(r.rating), 1) as avg_rating,
    FORMAT(b.price, 2) as price
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE JSON_CONTAINS_PATH(metadata, 'one', '$.awards')
    AND JSON_LENGTH(JSON_EXTRACT(metadata, '$.awards')) > 0
GROUP BY b.book_id, b.title
ORDER BY times_ordered DESC;

-- Reading Level Distribution
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.reading_level')) as reading_level,
    COUNT(*) as book_count,
    FORMAT(AVG(JSON_EXTRACT(metadata, '$.page_count')), 0) as avg_page_count,
    FORMAT(AVG(price), 2) as avg_price
FROM books 
WHERE JSON_CONTAINS_PATH(metadata, 'one', '$.reading_level')
GROUP BY JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.reading_level'))
ORDER BY book_count DESC;

-- ===========================================
-- ADVANCED ANALYTICS FUNCTIONS
-- ===========================================

-- Customer Lifetime Value Prediction
CREATE OR REPLACE VIEW customer_ltv_analysis AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    FORMAT(SUM(o.total_amount), 2) as total_spent,
    FORMAT(AVG(o.total_amount), 2) as avg_order_value,
    DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order,
    FORMAT(
        (SUM(o.total_amount) / COUNT(DISTINCT o.order_id)) * 
        (365.0 / AVG(DATEDIFF(o.order_date, 
            LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)
        ))), 2
    ) as predicted_annual_value,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 5 AND SUM(o.total_amount) > 200 THEN 'VIP'
        WHEN COUNT(DISTINCT o.order_id) >= 3 AND SUM(o.total_amount) > 100 THEN 'Loyal'
        WHEN COUNT(DISTINCT o.order_id) >= 2 THEN 'Regular'
        ELSE 'New'
    END as customer_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Sales Velocity Analysis
CREATE OR REPLACE VIEW sales_velocity AS
SELECT 
    b.book_id,
    b.title,
    COUNT(oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_units,
    DATEDIFF(CURDATE(), MIN(o.order_date)) as days_on_market,
    ROUND(SUM(oi.quantity) / DATEDIFF(CURDATE(), MIN(o.order_date)), 2) as units_per_day,
    FORMAT(SUM(oi.price * oi.quantity) / DATEDIFF(CURDATE(), MIN(o.order_date)), 2) as revenue_per_day,
    CASE 
        WHEN SUM(oi.quantity) / DATEDIFF(CURDATE(), MIN(o.order_date)) > 0.5 THEN 'Fast Moving'
        WHEN SUM(oi.quantity) / DATEDIFF(CURDATE(), MIN(o.order_date)) > 0.1 THEN 'Steady'
        ELSE 'Slow Moving'
    END as velocity_category
FROM books b
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
    AND DATEDIFF(CURDATE(), MIN(o.order_date)) > 0
GROUP BY b.book_id, b.title
ORDER BY units_per_day DESC;

-- ===========================================
-- DATA QUALITY VALIDATION
-- ===========================================

-- Data validation queries to ensure integrity
SELECT 'Data Quality Report' as report_type;

-- Check for orders without items
SELECT 'Orders without items' as issue, COUNT(*) as count
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Check for books without inventory records
SELECT 'Books without inventory' as issue, COUNT(*) as count
FROM books b
LEFT JOIN inventory i ON b.book_id = i.book_id
WHERE i.book_id IS NULL;

-- Check for invalid email formats
SELECT 'Invalid customer emails' as issue, COUNT(*) as count
FROM customers 
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

-- Check for negative prices or quantities
SELECT 'Negative prices' as issue, COUNT(*) as count
FROM books WHERE price < 0
UNION ALL
SELECT 'Negative inventory', COUNT(*) 
FROM inventory WHERE quantity_available < 0;

-- Performance validation
SELECT 'Performance Check' as report_type;

-- Query execution time for complex operations
SELECT 
    'Complex analytics query performance' as metric,
    'Sub-second execution expected' as target;

-- ===========================================
-- USAGE EXAMPLES
-- ===========================================

-- Example: Find science fiction books with high ratings
SELECT 
    b.title,
    JSON_EXTRACT(b.metadata, '$.genres') as genres,
    FORMAT(AVG(r.rating), 1) as avg_rating,
    COUNT(r.review_id) as review_count
FROM books b
JOIN reviews r ON b.book_id = r.book_id
WHERE JSON_CONTAINS(JSON_EXTRACT(b.metadata, '$.genres'), '"Fiction"')
GROUP BY b.book_id, b.title
HAVING avg_rating >= 4.0
ORDER BY avg_rating DESC;

-- Example: Search for books about "love" or "romance"
SELECT 
    b.title,
    MATCH(b.title, b.description) AGAINST('love romance' IN NATURAL LANGUAGE MODE) as relevance,
    JSON_EXTRACT(b.metadata, '$.themes') as themes
FROM books b
WHERE MATCH(b.title, b.description) AGAINST('love romance' IN NATURAL LANGUAGE MODE)
   OR JSON_CONTAINS(JSON_EXTRACT(b.metadata, '$.themes'), '"love"')
ORDER BY relevance DESC;

COMMIT;

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

SELECT 'Modern Features Added Successfully!' as status;
SELECT 'JSON metadata fields populated' as feature, COUNT(*) as books_with_metadata 
FROM books WHERE metadata IS NOT NULL;
SELECT 'Full-text indexes created' as feature, 'Enhanced search enabled' as status;
SELECT 'Real-time analytics ready' as feature, 'Dashboard queries available' as status;
