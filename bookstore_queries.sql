-- =========================================
-- SQL BOOKSTORE PROJECT - COMPREHENSIVE QUERIES
-- =========================================
-- This file contains a curated selection of the most important queries
-- demonstrating SQL proficiency across all skill levels
-- 
-- EXECUTION ORDER:
-- 1. Run 1_schema_creation.sql first
-- 2. Run 2_sample_data.sql second  
-- 3. Then execute queries from this file
-- =========================================

-- ===========================
-- SECTION 1: BASIC QUERIES (Beginner Level)
-- ===========================

-- 1.1 Simple SELECT with filtering and sorting
SELECT title, price, publication_date 
FROM books 
WHERE price BETWEEN 10 AND 20
ORDER BY price DESC;

-- 1.2 Aggregate functions
SELECT 
    COUNT(*) as total_books,
    AVG(price) as average_price,
    MIN(price) as cheapest_book,
    MAX(price) as most_expensive_book
FROM books;

-- 1.3 GROUP BY with HAVING
SELECT 
    c.category_name,
    COUNT(b.book_id) as book_count,
    ROUND(AVG(b.price), 2) as avg_price
FROM categories c
JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
HAVING book_count > 1
ORDER BY avg_price DESC;

-- ===========================
-- SECTION 2: INTERMEDIATE QUERIES
-- ===========================

-- 2.1 Complex JOINs with multiple tables
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    p.publisher_name,
    c.category_name,
    b.price,
    i.quantity_in_stock
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN inventory i ON b.book_id = i.book_id
ORDER BY b.title;

-- 2.2 Subqueries - Books more expensive than average
SELECT 
    title,
    price,
    (price - (SELECT AVG(price) FROM books)) as price_difference
FROM books
WHERE price > (SELECT AVG(price) FROM books)
ORDER BY price_difference DESC;

-- 2.3 Case statements for conditional logic
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.total_spent,
    c.membership_level,
    CASE 
        WHEN c.total_spent > 100 THEN 'High Value Customer'
        WHEN c.total_spent > 50 THEN 'Medium Value Customer'
        WHEN c.total_spent > 0 THEN 'Active Customer'
        ELSE 'Inactive Customer'
    END as customer_classification
FROM customers c
ORDER BY c.total_spent DESC;

-- ===========================
-- SECTION 3: ADVANCED QUERIES
-- ===========================

-- 3.1 Common Table Expression (CTE) with Window Functions
WITH sales_analysis AS (
    SELECT 
        b.book_id,
        b.title,
        CONCAT(a.first_name, ' ', a.last_name) as author,
        c.category_name,
        COALESCE(SUM(oi.quantity), 0) as units_sold,
        COALESCE(SUM(oi.total_price), 0) as revenue,
        RANK() OVER (ORDER BY COALESCE(SUM(oi.quantity), 0) DESC) as sales_rank,
        DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY COALESCE(SUM(oi.quantity), 0) DESC) as category_rank
    FROM books b
    JOIN authors a ON b.author_id = a.author_id
    JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
    GROUP BY b.book_id
)
SELECT 
    title,
    author,
    category_name,
    units_sold,
    ROUND(revenue, 2) as revenue,
    sales_rank,
    category_rank,
    CASE 
        WHEN sales_rank <= 5 THEN 'Bestseller'
        WHEN category_rank = 1 THEN 'Category Leader'
        WHEN units_sold = 0 THEN 'No Sales'
        ELSE 'Regular'
    END as performance_status
FROM sales_analysis
ORDER BY sales_rank;

-- 3.2 Complex business analysis - Customer Lifetime Value
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.membership_level,
        COUNT(DISTINCT o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MIN(o.order_date) as first_order,
        MAX(o.order_date) as last_order,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) as customer_lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id
),
ltv_calculation AS (
    SELECT 
        *,
        CASE 
            WHEN customer_lifespan_days > 0 THEN total_spent / (customer_lifespan_days / 365.0)
            ELSE total_spent
        END as annual_value,
        CASE 
            WHEN order_count > 1 THEN customer_lifespan_days / (order_count - 1)
            ELSE NULL
        END as avg_days_between_orders
    FROM customer_metrics
)
SELECT 
    customer_name,
    membership_level,
    order_count,
    ROUND(total_spent, 2) as lifetime_value,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(annual_value, 2) as annual_value,
    customer_lifespan_days,
    avg_days_between_orders,
    CASE 
        WHEN total_spent > 150 THEN 'VIP'
        WHEN total_spent > 75 THEN 'Loyal'
        WHEN order_count > 2 THEN 'Regular'
        ELSE 'New'
    END as customer_segment
FROM ltv_calculation
ORDER BY lifetime_value DESC;

-- ===========================
-- SECTION 4: ANALYTICS QUERIES
-- ===========================

-- 4.1 Monthly sales trends with growth analysis
WITH monthly_sales AS (
    SELECT 
        YEAR(o.order_date) as year,
        MONTH(o.order_date) as month,
        COUNT(DISTINCT o.order_id) as orders,
        SUM(o.total_amount) as revenue,
        COUNT(DISTINCT o.customer_id) as unique_customers
    FROM orders o
    WHERE o.order_status != 'Cancelled'
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
),
sales_with_growth AS (
    SELECT 
        *,
        LAG(revenue) OVER (ORDER BY year, month) as prev_month_revenue,
        LAG(orders) OVER (ORDER BY year, month) as prev_month_orders
    FROM monthly_sales
)
SELECT 
    year,
    month,
    MONTHNAME(CONCAT(year, '-', LPAD(month, 2, '0'), '-01')) as month_name,
    orders,
    ROUND(revenue, 2) as revenue,
    unique_customers,
    ROUND(revenue / orders, 2) as avg_order_value,
    CASE 
        WHEN prev_month_revenue IS NOT NULL THEN 
            ROUND(((revenue - prev_month_revenue) / prev_month_revenue) * 100, 2)
        ELSE NULL
    END as revenue_growth_percent
FROM sales_with_growth
ORDER BY year DESC, month DESC;

-- 4.2 Product performance matrix
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    c.category_name,
    b.price,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    COALESCE(SUM(oi.total_price), 0) as revenue,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(DISTINCT r.review_id) as review_count,
    i.quantity_in_stock,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) >= 10 AND COALESCE(AVG(r.rating), 0) >= 4 THEN 'Star Product'
        WHEN COALESCE(SUM(oi.quantity), 0) >= 10 THEN 'High Sales'
        WHEN COALESCE(AVG(r.rating), 0) >= 4 THEN 'High Quality'
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'No Sales'
        ELSE 'Average'
    END as product_classification
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
LEFT JOIN inventory i ON b.book_id = i.book_id
GROUP BY b.book_id
ORDER BY revenue DESC, avg_rating DESC;

-- ===========================
-- SECTION 5: BUSINESS INTELLIGENCE QUERIES
-- ===========================

-- 5.1 Customer Segmentation using RFM Analysis
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        DATEDIFF(CURDATE(), MAX(o.order_date)) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        SUM(o.total_amount) as monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC) as recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) as frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) as monetary_score
    FROM customer_rfm
)
SELECT 
    customer_name,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) as total_spent,
    CONCAT(recency_score, frequency_score, monetary_score) as rfm_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost Customers'
        ELSE 'Regular Customers'
    END as customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC;

-- 5.2 Inventory optimization report
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    c.category_name,
    b.price,
    i.quantity_in_stock,
    i.reorder_level,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'URGENT - Reorder Now'
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 'LOW - Monitor'
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'EXCESS - No Sales'
        ELSE 'ADEQUATE'
    END as stock_status,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) >= 15 THEN 'Fast Moving'
        WHEN COALESCE(SUM(oi.quantity), 0) >= 5 THEN 'Medium Moving'
        WHEN COALESCE(SUM(oi.quantity), 0) > 0 THEN 'Slow Moving'
        ELSE 'Dead Stock'
    END as movement_category,
    ROUND(b.price * COALESCE(SUM(oi.quantity), 0), 2) as revenue_generated
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
JOIN inventory i ON b.book_id = i.book_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
GROUP BY b.book_id
ORDER BY 
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 1
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 2
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 4
        ELSE 3
    END,
    total_sold DESC;

-- ===========================
-- SECTION 6: SPECIALIZED QUERIES
-- ===========================

-- 6.1 Publisher performance comparison
SELECT 
    p.publisher_name,
    COUNT(DISTINCT b.book_id) as books_published,
    COALESCE(SUM(oi.quantity), 0) as total_units_sold,
    COALESCE(SUM(oi.total_price), 0) as total_revenue,
    ROUND(COALESCE(AVG(r.rating), 0), 2) as avg_rating,
    COUNT(DISTINCT r.review_id) as total_reviews,
    ROUND(
        COALESCE(SUM(oi.total_price), 0) / NULLIF(COUNT(DISTINCT b.book_id), 0), 2
    ) as revenue_per_book
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY p.publisher_id
HAVING books_published > 0
ORDER BY total_revenue DESC;

-- 6.2 Author popularity and sales analysis
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    a.nationality,
    COUNT(DISTINCT b.book_id) as books_written,
    COALESCE(SUM(oi.quantity), 0) as total_books_sold,
    COALESCE(SUM(oi.total_price), 0) as total_revenue,
    ROUND(COALESCE(AVG(r.rating), 0), 2) as avg_rating,
    COUNT(DISTINCT r.review_id) as total_reviews,
    ROUND(COALESCE(AVG(b.price), 0), 2) as avg_book_price
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY a.author_id
HAVING books_written > 0
ORDER BY total_revenue DESC;

-- ===========================
-- SECTION 7: SUMMARY REPORTS
-- ===========================

-- 7.1 Executive dashboard summary
SELECT 
    'Total Books' as metric,
    COUNT(*) as value,
    NULL as percentage
FROM books

UNION ALL

SELECT 
    'Total Customers',
    COUNT(*),
    NULL
FROM customers

UNION ALL

SELECT 
    'Total Orders',
    COUNT(*),
    NULL
FROM orders
WHERE order_status != 'Cancelled'

UNION ALL

SELECT 
    'Total Revenue',
    ROUND(SUM(total_amount), 2),
    NULL
FROM orders
WHERE order_status != 'Cancelled'

UNION ALL

SELECT 
    'Average Order Value',
    ROUND(AVG(total_amount), 2),
    NULL
FROM orders
WHERE order_status != 'Cancelled'

UNION ALL

SELECT 
    'Books with Reviews',
    COUNT(DISTINCT b.book_id),
    ROUND((COUNT(DISTINCT b.book_id) * 100.0 / (SELECT COUNT(*) FROM books)), 2)
FROM books b
JOIN reviews r ON b.book_id = r.book_id;

-- 7.2 Category performance summary
SELECT 
    c.category_name,
    COUNT(DISTINCT b.book_id) as total_books,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    COALESCE(ROUND(SUM(oi.total_price), 2), 0) as revenue,
    ROUND(COALESCE(AVG(b.price), 0), 2) as avg_price,
    ROUND(COALESCE(AVG(r.rating), 0), 2) as avg_rating,
    CASE 
        WHEN COALESCE(SUM(oi.total_price), 0) > 300 THEN 'High Performer'
        WHEN COALESCE(SUM(oi.total_price), 0) > 150 THEN 'Medium Performer'
        WHEN COALESCE(SUM(oi.total_price), 0) > 0 THEN 'Low Performer'
        ELSE 'No Sales'
    END as performance_tier
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY c.category_id, c.category_name
ORDER BY revenue DESC;

-- ===========================
-- FINAL VERIFICATION QUERIES
-- ===========================

-- Data integrity checks
SELECT 'Data Integrity Check' as check_type;

-- Check for orphaned records
SELECT 'Orphaned Books (no author)' as issue, COUNT(*) as count
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
WHERE a.author_id IS NULL

UNION ALL

SELECT 'Orders without items', COUNT(*)
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL

UNION ALL

SELECT 'Books without inventory', COUNT(*)
FROM books b
LEFT JOIN inventory i ON b.book_id = i.book_id
WHERE i.book_id IS NULL;

-- Performance summary
SELECT 
    'SQL Bookstore Project - Analysis Complete' as status,
    CURDATE() as analysis_date,
    'All queries executed successfully' as result;
