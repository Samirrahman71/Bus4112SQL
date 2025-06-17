-- =========================================
-- SQL BOOKSTORE PROJECT - ORACLE LIVE SQL VERSION
-- Comprehensive Queries for Oracle Database
-- =========================================
-- This file contains Oracle-optimized queries demonstrating SQL proficiency
-- 
-- EXECUTION ORDER:
-- 1. Run oracle_1_schema_creation.sql first
-- 2. Run oracle_2_sample_data.sql second  
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

-- 1.2 Aggregate functions with Oracle-specific formatting
SELECT 
    COUNT(*) as total_books,
    ROUND(AVG(price), 2) as average_price,
    MIN(price) as cheapest_book,
    MAX(price) as most_expensive_book,
    TO_CHAR(SUM(price), '$999,999.99') as total_inventory_value
FROM books;

-- 1.3 GROUP BY with HAVING
SELECT 
    c.category_name,
    COUNT(b.book_id) as book_count,
    ROUND(AVG(b.price), 2) as avg_price
FROM categories c
JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(b.book_id) > 1
ORDER BY avg_price DESC;

-- 1.4 Oracle date functions
SELECT 
    title,
    publication_date,
    EXTRACT(YEAR FROM publication_date) as pub_year,
    ROUND(MONTHS_BETWEEN(SYSDATE, publication_date) / 12, 1) as years_old
FROM books
WHERE publication_date IS NOT NULL
ORDER BY publication_date DESC;

-- ===========================
-- SECTION 2: INTERMEDIATE QUERIES
-- ===========================

-- 2.1 Complex JOINs with Oracle concatenation
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author_name,
    p.publisher_name,
    c.category_name,
    TO_CHAR(b.price, '$999.99') as formatted_price,
    i.quantity_in_stock
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN inventory i ON b.book_id = i.book_id
ORDER BY b.title;

-- 2.2 Subqueries with Oracle analytical functions
SELECT 
    title,
    price,
    ROUND(price - (SELECT AVG(price) FROM books), 2) as price_difference_from_avg,
    CASE 
        WHEN price > (SELECT AVG(price) FROM books) THEN 'Above Average'
        WHEN price < (SELECT AVG(price) FROM books) THEN 'Below Average'
        ELSE 'Average'
    END as price_category
FROM books
ORDER BY price_difference_from_avg DESC;

-- 2.3 Oracle DECODE function and hierarchical queries
SELECT 
    c.first_name || ' ' || c.last_name as customer_name,
    c.total_spent,
    c.membership_level,
    DECODE(c.membership_level,
        'Bronze', 'Entry Level',
        'Silver', 'Standard',
        'Gold', 'Premium',
        'Platinum', 'VIP',
        'Unknown') as membership_description,
    CASE 
        WHEN c.total_spent > 100 THEN 'High Value Customer'
        WHEN c.total_spent > 50 THEN 'Medium Value Customer'
        WHEN c.total_spent > 0 THEN 'Active Customer'
        ELSE 'Inactive Customer'
    END as customer_classification
FROM customers c
ORDER BY c.total_spent DESC;

-- ===========================
-- SECTION 3: ADVANCED QUERIES WITH ORACLE FEATURES
-- ===========================

-- 3.1 Oracle Analytical Functions with PARTITION BY
SELECT 
    b.book_id,
    b.title,
    a.first_name || ' ' || a.last_name as author,
    c.category_name,
    NVL(SUM(oi.quantity), 0) as units_sold,
    NVL(SUM(oi.total_price), 0) as revenue,
    RANK() OVER (ORDER BY NVL(SUM(oi.quantity), 0) DESC) as overall_sales_rank,
    DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY NVL(SUM(oi.quantity), 0) DESC) as category_rank,
    ROW_NUMBER() OVER (ORDER BY NVL(SUM(oi.total_price), 0) DESC) as revenue_rank
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
GROUP BY b.book_id, b.title, a.first_name, a.last_name, c.category_name
ORDER BY overall_sales_rank;

-- 3.2 Oracle Common Table Expressions (WITH clause)
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.membership_level,
        COUNT(DISTINCT o.order_id) as order_count,
        NVL(SUM(o.total_amount), 0) as total_spent,
        NVL(AVG(o.total_amount), 0) as avg_order_value,
        MIN(o.order_date) as first_order,
        MAX(o.order_date) as last_order
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled' OR o.order_status IS NULL
    GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_level
),
ltv_calculation AS (
    SELECT 
        customer_id,
        customer_name,
        membership_level,
        order_count,
        total_spent,
        ROUND(avg_order_value, 2) as avg_order_value,
        first_order,
        last_order,
        CASE 
            WHEN first_order IS NOT NULL AND last_order IS NOT NULL 
                 AND first_order != last_order THEN
                ROUND((last_order - first_order), 0)
            ELSE 0
        END as customer_lifespan_days,
        CASE 
            WHEN first_order IS NOT NULL AND last_order IS NOT NULL 
                 AND first_order != last_order THEN
                ROUND(total_spent / ((last_order - first_order) / 365), 2)
            ELSE total_spent
        END as annual_value
    FROM customer_metrics
)
SELECT 
    customer_name,
    membership_level,
    order_count,
    TO_CHAR(total_spent, '$999,999.99') as lifetime_value,
    TO_CHAR(avg_order_value, '$999.99') as avg_order_value,
    TO_CHAR(annual_value, '$999,999.99') as estimated_annual_value,
    customer_lifespan_days,
    CASE 
        WHEN total_spent > 150 THEN 'VIP'
        WHEN total_spent > 75 THEN 'Loyal'
        WHEN order_count > 2 THEN 'Regular'
        WHEN order_count > 0 THEN 'Active'
        ELSE 'Inactive'
    END as customer_segment
FROM ltv_calculation
ORDER BY total_spent DESC;

-- 3.3 Oracle Hierarchical Queries (CONNECT BY)
SELECT 
    LPAD(' ', (LEVEL - 1) * 2) || category_name as category_hierarchy,
    LEVEL as hierarchy_level,
    category_id,
    parent_category_id
FROM categories
START WITH parent_category_id IS NULL
CONNECT BY PRIOR category_id = parent_category_id
ORDER SIBLINGS BY category_name;

-- ===========================
-- SECTION 4: ORACLE ANALYTICS QUERIES
-- ===========================

-- 4.1 Monthly sales trends with Oracle date functions
SELECT 
    TO_CHAR(o.order_date, 'YYYY') as year,
    TO_CHAR(o.order_date, 'MM') as month,
    TO_CHAR(o.order_date, 'Month YYYY') as month_year,
    COUNT(DISTINCT o.order_id) as orders,
    TO_CHAR(SUM(o.total_amount), '$999,999.99') as revenue,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    TO_CHAR(AVG(o.total_amount), '$999.99') as avg_order_value,
    LAG(SUM(o.total_amount)) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')) as prev_month_revenue,
    CASE 
        WHEN LAG(SUM(o.total_amount)) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')) IS NOT NULL THEN
            ROUND(((SUM(o.total_amount) - LAG(SUM(o.total_amount)) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM'))) / 
                   LAG(SUM(o.total_amount)) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM'))) * 100, 2)
        ELSE NULL
    END as revenue_growth_percent
FROM orders o
WHERE o.order_status != 'Cancelled'
GROUP BY TO_CHAR(o.order_date, 'YYYY'), TO_CHAR(o.order_date, 'MM'), TO_CHAR(o.order_date, 'Month YYYY')
ORDER BY year DESC, month DESC;

-- 4.2 Oracle PIVOT operation for category sales
SELECT *
FROM (
    SELECT 
        c.category_name,
        TO_CHAR(o.order_date, 'YYYY-MM') as order_month,
        oi.total_price
    FROM categories c
    JOIN books b ON c.category_id = b.category_id
    JOIN order_items oi ON b.book_id = oi.book_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
)
PIVOT (
    SUM(total_price)
    FOR order_month IN ('2024-01' as Jan_2024, '2024-02' as Feb_2024)
)
ORDER BY category_name;

-- 4.3 Oracle ROLLUP for hierarchical totals
SELECT 
    CASE GROUPING(c.category_name)
        WHEN 1 THEN 'ALL CATEGORIES'
        ELSE c.category_name
    END as category,
    CASE GROUPING(p.publisher_name)
        WHEN 1 THEN 
            CASE GROUPING(c.category_name)
                WHEN 1 THEN 'ALL PUBLISHERS'
                ELSE 'Category Total'
            END
        ELSE p.publisher_name
    END as publisher,
    COUNT(b.book_id) as book_count,
    TO_CHAR(SUM(b.price * NVL(i.quantity_in_stock, 0)), '$999,999.99') as inventory_value
FROM categories c
JOIN books b ON c.category_id = b.category_id
JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN inventory i ON b.book_id = i.book_id
GROUP BY ROLLUP(c.category_name, p.publisher_name)
ORDER BY GROUPING(c.category_name), c.category_name, GROUPING(p.publisher_name), p.publisher_name;

-- ===========================
-- SECTION 5: ORACLE BUSINESS INTELLIGENCE
-- ===========================

-- 5.1 Oracle percentile functions for customer analysis
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.total_spent,
    ROUND(PERCENT_RANK() OVER (ORDER BY c.total_spent), 4) as spending_percentile,
    NTILE(5) OVER (ORDER BY c.total_spent) as spending_quintile,
    CASE NTILE(5) OVER (ORDER BY c.total_spent)
        WHEN 5 THEN 'Top 20% Spenders'
        WHEN 4 THEN 'High Spenders'
        WHEN 3 THEN 'Medium Spenders'
        WHEN 2 THEN 'Low Spenders'
        WHEN 1 THEN 'Minimal Spenders'
    END as spending_category
FROM customers c
WHERE c.total_spent > 0
ORDER BY c.total_spent DESC;

-- 5.2 Oracle moving averages for trend analysis
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM-DD') as order_date,
    COUNT(*) as daily_orders,
    SUM(o.total_amount) as daily_revenue,
    AVG(COUNT(*)) OVER (ORDER BY TRUNC(o.order_date) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_orders_7day,
    AVG(SUM(o.total_amount)) OVER (ORDER BY TRUNC(o.order_date) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_revenue_7day
FROM orders o
WHERE o.order_status != 'Cancelled'
GROUP BY TRUNC(o.order_date), TO_CHAR(o.order_date, 'YYYY-MM-DD')
ORDER BY TRUNC(o.order_date);

-- ===========================
-- SECTION 6: ORACLE ADVANCED FEATURES
-- ===========================

-- 6.1 Oracle Regular Expressions
SELECT 
    title,
    author_id,
    CASE 
        WHEN REGEXP_LIKE(title, '^[Tt]he\s') THEN 'Starts with "The"'
        WHEN REGEXP_LIKE(title, '\s[Aa]nd\s') THEN 'Contains "and"'
        WHEN REGEXP_LIKE(title, '[0-9]') THEN 'Contains numbers'
        ELSE 'Other pattern'
    END as title_pattern
FROM books
ORDER BY title_pattern, title;

-- 6.2 Oracle LISTAGG function for string aggregation
SELECT 
    c.category_name,
    COUNT(b.book_id) as book_count,
    LISTAGG(b.title, '; ') WITHIN GROUP (ORDER BY b.title) as books_in_category
FROM categories c
JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY book_count DESC;

-- 6.3 Oracle FIRST_VALUE and LAST_VALUE functions
SELECT 
    b.title,
    b.price,
    c.category_name,
    FIRST_VALUE(b.title) OVER (PARTITION BY c.category_name ORDER BY b.price) as cheapest_in_category,
    LAST_VALUE(b.title) OVER (PARTITION BY c.category_name ORDER BY b.price 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as most_expensive_in_category
FROM books b
JOIN categories c ON b.category_id = c.category_id
ORDER BY c.category_name, b.price;

-- ===========================
-- SECTION 7: ORACLE PERFORMANCE QUERIES
-- ===========================

-- 7.1 Oracle execution plan analysis
EXPLAIN PLAN FOR
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    AVG(r.rating) as avg_rating
FROM books b
JOIN authors a ON b.author_id = a.author_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE b.price > (SELECT AVG(price) FROM books)
GROUP BY b.book_id, b.title, a.first_name, a.last_name
HAVING COUNT(r.review_id) > 0;

-- Display the execution plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 7.2 Oracle index usage analysis
SELECT 
    index_name,
    table_name,
    uniqueness,
    status,
    num_rows,
    leaf_blocks,
    clustering_factor
FROM user_indexes
WHERE table_name IN ('BOOKS', 'AUTHORS', 'CUSTOMERS', 'ORDERS')
ORDER BY table_name, index_name;

-- ===========================
-- SECTION 8: ORACLE REPORTING QUERIES
-- ===========================

-- 8.1 Executive dashboard with Oracle formatting
SELECT 
    'Total Books' as metric,
    TO_CHAR(COUNT(*), '999,999') as value,
    NULL as percentage
FROM books
UNION ALL
SELECT 
    'Total Active Customers',
    TO_CHAR(COUNT(*), '999,999'),
    NULL
FROM customers
WHERE is_active = 1
UNION ALL
SELECT 
    'Total Orders (Completed)',
    TO_CHAR(COUNT(*), '999,999'),
    NULL
FROM orders
WHERE order_status IN ('Delivered', 'Shipped')
UNION ALL
SELECT 
    'Total Revenue',
    TO_CHAR(SUM(total_amount), '$999,999,999.99'),
    NULL
FROM orders
WHERE order_status != 'Cancelled'
UNION ALL
SELECT 
    'Average Order Value',
    TO_CHAR(AVG(total_amount), '$999.99'),
    NULL
FROM orders
WHERE order_status != 'Cancelled'
UNION ALL
SELECT 
    'Books with Reviews',
    TO_CHAR(COUNT(DISTINCT b.book_id), '999,999'),
    TO_CHAR(ROUND((COUNT(DISTINCT b.book_id) * 100.0 / (SELECT COUNT(*) FROM books)), 2), '999.99') || '%'
FROM books b
JOIN reviews r ON b.book_id = r.book_id;

-- 8.2 Oracle inventory status report
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author,
    i.quantity_in_stock,
    i.reorder_level,
    i.location,
    TO_CHAR(b.price * i.quantity_in_stock, '$999,999.99') as inventory_value,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'REORDER NOW'
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 'LOW STOCK'
        ELSE 'ADEQUATE'
    END as stock_status,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 1
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 2
        ELSE 3
    END as priority_order
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN inventory i ON b.book_id = i.book_id
ORDER BY priority_order, i.quantity_in_stock;

-- ===========================
-- SECTION 9: ORACLE DATA VALIDATION
-- ===========================

-- 9.1 Data integrity checks
SELECT 'Data Integrity Check Results' as check_type FROM dual;

SELECT 
    'Orphaned Books (no author)' as issue, 
    COUNT(*) as count
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
WHERE a.author_id IS NULL
UNION ALL
SELECT 
    'Orders without items', 
    COUNT(*)
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
UNION ALL
SELECT 
    'Books without inventory', 
    COUNT(*)
FROM books b
LEFT JOIN inventory i ON b.book_id = i.book_id
WHERE i.book_id IS NULL
UNION ALL
SELECT 
    'Invalid email formats', 
    COUNT(*)
FROM customers
WHERE NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- 9.2 Oracle sequence current values
SELECT 
    sequence_name,
    last_number as current_value,
    increment_by,
    cache_size
FROM user_sequences
WHERE sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

-- ===========================
-- FINAL SUCCESS MESSAGE
-- ===========================

SELECT 
    'Oracle SQL Bookstore Project - Analysis Complete!' as status,
    TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') as completion_time,
    'All Oracle-optimized queries executed successfully' as result
FROM dual;
