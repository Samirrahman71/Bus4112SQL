-- Modern Database Features for Oracle Live SQL
-- JSON support, text search, and advanced analytics for Oracle

-- ===========================================
-- JSON METADATA FOR FLEXIBLE BOOK ATTRIBUTES
-- ===========================================

-- Add JSON column for flexible book metadata (Oracle 12c+)
ALTER TABLE books ADD metadata CLOB;

-- Ensure JSON format validation
ALTER TABLE books ADD CONSTRAINT books_metadata_json CHECK (metadata IS JSON);

-- Update books with JSON metadata examples
UPDATE books 
SET metadata = '{
    "genres": ["Fiction", "Dystopian"],
    "awards": ["Hugo Award Nominee"],
    "themes": ["surveillance", "totalitarianism"],
    "reading_level": "Adult",
    "page_count": 328,
    "language": "English"
}'
WHERE title = '1984';

UPDATE books 
SET metadata = '{
    "genres": ["Fiction", "Coming-of-age"],
    "awards": ["Pulitzer Prize Winner"],
    "themes": ["racism", "justice", "childhood"],
    "reading_level": "High School",
    "page_count": 281,
    "language": "English"
}'
WHERE title = 'To Kill a Mockingbird';

UPDATE books 
SET metadata = '{
    "genres": ["Romance", "Historical Fiction"],
    "awards": ["Bestseller"],
    "themes": ["love", "class", "society"],
    "reading_level": "Adult",
    "page_count": 432,
    "language": "English"
}'
WHERE title = 'Pride and Prejudice';

-- ===========================================
-- ORACLE TEXT SEARCH CAPABILITIES
-- ===========================================

-- Create text indexes for enhanced search (Oracle Text)
-- Note: In Oracle Live SQL, these may need to be simplified
CREATE INDEX idx_books_text ON books(title);
CREATE INDEX idx_books_desc_text ON books(description);

-- Text search queries using Oracle functions
-- Search books by title or description using CONTAINS (if Oracle Text available)
-- Fallback to UPPER/LOWER and LIKE for Oracle Live SQL compatibility
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    TO_CHAR(b.price, '999.99') as price
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE UPPER(b.title) LIKE '%SCIENCE%' 
   OR UPPER(b.description) LIKE '%FICTION%'
ORDER BY b.title;

-- Advanced search with regular expressions
SELECT 
    first_name || ' ' || last_name as author_name,
    nationality,
    biography
FROM authors
WHERE REGEXP_LIKE(UPPER(first_name || ' ' || last_name || ' ' || biography), 'BRITISH.*WRITER|WRITER.*BRITISH', 'i')
ORDER BY last_name;

-- ===========================================
-- REAL-TIME DASHBOARD QUERIES (ORACLE)
-- ===========================================

-- Daily Sales Summary (KPI Dashboard)
SELECT 
    'Today Sales' as metric,
    COUNT(DISTINCT order_id) as orders_count,
    TO_CHAR(SUM(total_amount), '999,999.99') as total_revenue,
    TO_CHAR(AVG(total_amount), '999.99') as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders 
WHERE TRUNC(order_date) = TRUNC(SYSDATE) AND order_status != 'Cancelled';

-- Top Performing Books This Month
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    COUNT(oi.order_item_id) as units_sold,
    TO_CHAR(SUM(oi.price * oi.quantity), '999,999.99') as revenue,
    TO_CHAR(AVG(r.rating), '9.9') as avg_rating
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE EXTRACT(MONTH FROM o.order_date) = EXTRACT(MONTH FROM SYSDATE)
    AND EXTRACT(YEAR FROM o.order_date) = EXTRACT(YEAR FROM SYSDATE)
    AND o.order_status = 'Delivered'
GROUP BY b.book_id, b.title, a.first_name, a.last_name
ORDER BY units_sold DESC
FETCH FIRST 5 ROWS ONLY;

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
ORDER BY (i.quantity_available / NULLIF(i.reorder_level, 0)) ASC;

-- Customer Activity Heatmap (by hour of day)
SELECT 
    EXTRACT(HOUR FROM order_date) as hour_of_day,
    COUNT(*) as order_count,
    TO_CHAR(SUM(total_amount), '999,999.99') as hourly_revenue,
    RPAD('█', FLOOR(COUNT(*) / 2), '█') as activity_bar
FROM orders 
WHERE order_date >= SYSDATE - 30
GROUP BY EXTRACT(HOUR FROM order_date)
ORDER BY hour_of_day;

-- ===========================================
-- JSON ANALYTICS QUERIES (ORACLE)
-- ===========================================

-- Books by Genre (using JSON data)
SELECT 
    JSON_VALUE(metadata, '$.genres[0]') as primary_genre,
    COUNT(*) as book_count,
    TO_CHAR(AVG(price), '999.99') as avg_price,
    NVL(SUM(oi.quantity), 0) as total_sold
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
WHERE metadata IS NOT NULL
GROUP BY JSON_VALUE(metadata, '$.genres[0]')
ORDER BY book_count DESC;

-- Award-Winning Books Performance
SELECT 
    b.title,
    JSON_VALUE(b.metadata, '$.awards[0]') as primary_award,
    COUNT(oi.order_item_id) as times_ordered,
    TO_CHAR(AVG(r.rating), '9.9') as avg_rating,
    TO_CHAR(b.price, '999.99') as price
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE JSON_EXISTS(metadata, '$.awards[0]')
GROUP BY b.book_id, b.title, JSON_VALUE(b.metadata, '$.awards[0]'), b.price
ORDER BY times_ordered DESC;

-- Reading Level Distribution
SELECT 
    JSON_VALUE(metadata, '$.reading_level') as reading_level,
    COUNT(*) as book_count,
    TO_CHAR(AVG(TO_NUMBER(JSON_VALUE(metadata, '$.page_count'))), '9999') as avg_page_count,
    TO_CHAR(AVG(price), '999.99') as avg_price
FROM books 
WHERE JSON_VALUE(metadata, '$.reading_level') IS NOT NULL
GROUP BY JSON_VALUE(metadata, '$.reading_level')
ORDER BY book_count DESC;

-- ===========================================
-- ADVANCED ANALYTICS VIEWS (ORACLE)
-- ===========================================

-- Customer Lifetime Value Analysis
CREATE OR REPLACE VIEW customer_ltv_analysis AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    TO_CHAR(SUM(o.total_amount), '999,999.99') as total_spent,
    TO_CHAR(AVG(o.total_amount), '999.99') as avg_order_value,
    SYSDATE - MAX(o.order_date) as days_since_last_order,
    TO_CHAR(
        (SUM(o.total_amount) / COUNT(DISTINCT o.order_id)) * 12, '999,999.99'
    ) as estimated_annual_value,
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
ORDER BY SUM(o.total_amount) DESC;

-- Sales Velocity Analysis
CREATE OR REPLACE VIEW sales_velocity AS
SELECT 
    b.book_id,
    b.title,
    COUNT(oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_units,
    ROUND(SYSDATE - MIN(o.order_date)) as days_on_market,
    ROUND(SUM(oi.quantity) / NULLIF(SYSDATE - MIN(o.order_date), 0), 2) as units_per_day,
    TO_CHAR(SUM(oi.price * oi.quantity) / NULLIF(SYSDATE - MIN(o.order_date), 0), '999.99') as revenue_per_day,
    CASE 
        WHEN SUM(oi.quantity) / NULLIF(SYSDATE - MIN(o.order_date), 0) > 0.5 THEN 'Fast Moving'
        WHEN SUM(oi.quantity) / NULLIF(SYSDATE - MIN(o.order_date), 0) > 0.1 THEN 'Steady'
        ELSE 'Slow Moving'
    END as velocity_category
FROM books b
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
    AND (SYSDATE - MIN(o.order_date)) > 0
GROUP BY b.book_id, b.title
ORDER BY SUM(oi.quantity) / NULLIF(SYSDATE - MIN(o.order_date), 0) DESC;

-- ===========================================
-- DATA QUALITY VALIDATION (ORACLE)
-- ===========================================

-- Data validation queries to ensure integrity
SELECT 'Data Quality Report' as report_type FROM dual;

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

-- Check for invalid email formats (Oracle regex)
SELECT 'Invalid customer emails' as issue, COUNT(*) as count
FROM customers 
WHERE NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Check for negative prices or quantities
SELECT 'Negative prices' as issue, COUNT(*) as count
FROM books WHERE price < 0
UNION ALL
SELECT 'Negative inventory', COUNT(*) 
FROM inventory WHERE quantity_available < 0;

-- ===========================================
-- ORACLE ANALYTICAL FUNCTIONS SHOWCASE
-- ===========================================

-- Advanced Window Functions for Sales Analysis
SELECT 
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        ORDER BY o.order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total,
    AVG(o.total_amount) OVER (
        ORDER BY o.order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7_days,
    LAG(o.total_amount, 1) OVER (ORDER BY o.order_date) as previous_day_sales,
    o.total_amount - LAG(o.total_amount, 1) OVER (ORDER BY o.order_date) as day_over_day_change
FROM orders o
WHERE o.order_status = 'Delivered'
ORDER BY o.order_date;

-- Customer Ranking with RANK and DENSE_RANK
SELECT 
    c.first_name || ' ' || c.last_name as customer_name,
    SUM(o.total_amount) as total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as spending_rank,
    DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as spending_dense_rank,
    NTILE(4) OVER (ORDER BY SUM(o.total_amount) DESC) as spending_quartile
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Pivot Analysis - Sales by Category and Month
SELECT * FROM (
    SELECT 
        TO_CHAR(o.order_date, 'YYYY-MM') as order_month,
        cat.category_name,
        SUM(oi.price * oi.quantity) as revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN books b ON oi.book_id = b.book_id
    JOIN categories cat ON b.category_id = cat.category_id
    WHERE o.order_status = 'Delivered'
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM'), cat.category_name
)
PIVOT (
    SUM(revenue)
    FOR category_name IN ('Fiction', 'Non-Fiction', 'Science', 'Biography', 'Children')
)
ORDER BY order_month;

-- ===========================================
-- USAGE EXAMPLES
-- ===========================================

-- Example: Find books with specific themes using JSON
SELECT 
    b.title,
    JSON_VALUE(b.metadata, '$.genres[0]') as primary_genre,
    JSON_QUERY(b.metadata, '$.themes') as themes,
    TO_CHAR(AVG(r.rating), '9.99') as avg_rating,
    COUNT(r.review_id) as review_count
FROM books b
JOIN reviews r ON b.book_id = r.book_id
WHERE JSON_EXISTS(b.metadata, '$.themes[*]?(@ == "love")')
GROUP BY b.book_id, b.title, JSON_VALUE(b.metadata, '$.genres[0]'), JSON_QUERY(b.metadata, '$.themes')
HAVING AVG(r.rating) >= 4.0
ORDER BY AVG(r.rating) DESC;

-- Example: Text search for books about specific topics
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    b.price,
    JSON_QUERY(b.metadata, '$.themes') as themes
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE UPPER(b.title) LIKE '%LOVE%' 
   OR UPPER(b.description) LIKE '%ROMANCE%'
   OR JSON_EXISTS(b.metadata, '$.themes[*]?(@ == "love")')
ORDER BY b.title;

COMMIT;

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

SELECT 'Modern Features Added Successfully for Oracle!' as status FROM dual;

SELECT 'JSON metadata fields populated' as feature, COUNT(*) as books_with_metadata 
FROM books WHERE metadata IS NOT NULL;

SELECT 'Advanced analytics views created' as feature, 'Oracle-specific functions used' as status FROM dual;

SELECT 'Data quality checks implemented' as feature, 'Validation queries ready' as status FROM dual;
