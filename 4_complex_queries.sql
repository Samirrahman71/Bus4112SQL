-- =========================================
-- SQL BOOKSTORE PROJECT - COMPLEX QUERIES
-- =========================================
-- This file demonstrates advanced SQL operations and complex data analysis
-- Skills: Advanced JOINs, CTEs, Window Functions, Complex Subqueries, Set Operations

-- ===========================
-- 1. ADVANCED JOINS
-- ===========================

-- Books with their reviews (LEFT JOIN to include books without reviews)
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.price,
    r.rating,
    r.review_title,
    CONCAT(c.first_name, ' ', c.last_name) as reviewer
FROM books b
LEFT JOIN reviews r ON b.book_id = r.book_id
LEFT JOIN customers c ON r.customer_id = c.customer_id
JOIN authors a ON b.author_id = a.author_id
ORDER BY b.title, r.rating DESC;

-- Books that have never been ordered
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.price,
    c.category_name
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
WHERE oi.book_id IS NULL
ORDER BY b.title;

-- Customers with their order history
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.membership_level,
    o.order_date,
    o.order_status,
    o.total_amount,
    COUNT(oi.order_item_id) as items_in_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, o.order_id
ORDER BY c.last_name, o.order_date DESC;

-- ===========================
-- 2. COMPLEX SUBQUERIES
-- ===========================

-- Books with above-average ratings
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.price,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN reviews r ON b.book_id = r.book_id
GROUP BY b.book_id
HAVING AVG(r.rating) > (
    SELECT AVG(rating) FROM reviews
)
ORDER BY avg_rating DESC;

-- Customers who spent more than average
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.total_spent,
    c.membership_level,
    (c.total_spent - avg_spent.avg_amount) as above_average_by
FROM customers c
CROSS JOIN (
    SELECT AVG(total_spent) as avg_amount 
    FROM customers 
    WHERE total_spent > 0
) avg_spent
WHERE c.total_spent > avg_spent.avg_amount
ORDER BY c.total_spent DESC;

-- Most popular books (by order quantity)
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.price,
    SUM(oi.quantity) as total_sold,
    COUNT(DISTINCT oi.order_id) as unique_orders
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY b.book_id
ORDER BY total_sold DESC
LIMIT 10;

-- ===========================
-- 3. COMMON TABLE EXPRESSIONS (CTEs)
-- ===========================

-- Customer purchase patterns with CTEs
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.membership_level,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MIN(o.order_date) as first_order_date,
        MAX(o.order_date) as last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id
),
customer_rankings AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_spent DESC) as spending_rank,
        RANK() OVER (ORDER BY total_orders DESC) as order_count_rank
    FROM customer_stats
)
SELECT 
    customer_name,
    membership_level,
    total_orders,
    total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    spending_rank,
    order_count_rank,
    DATEDIFF(last_order_date, first_order_date) as days_as_customer
FROM customer_rankings
ORDER BY spending_rank;

-- Category performance analysis
WITH category_sales AS (
    SELECT 
        c.category_name,
        COUNT(DISTINCT b.book_id) as books_in_category,
        SUM(oi.quantity) as total_units_sold,
        SUM(oi.total_price) as total_revenue,
        AVG(b.price) as avg_book_price
    FROM categories c
    LEFT JOIN books b ON c.category_id = b.category_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled' OR o.order_id IS NULL
    GROUP BY c.category_id
)
SELECT 
    category_name,
    books_in_category,
    COALESCE(total_units_sold, 0) as units_sold,
    COALESCE(total_revenue, 0) as revenue,
    ROUND(COALESCE(avg_book_price, 0), 2) as avg_price,
    CASE 
        WHEN total_revenue > 500 THEN 'High Performer'
        WHEN total_revenue > 200 THEN 'Medium Performer'
        WHEN total_revenue > 0 THEN 'Low Performer'
        ELSE 'No Sales'
    END as performance_category
FROM category_sales
ORDER BY total_revenue DESC NULLS LAST;

-- ===========================
-- 4. WINDOW FUNCTIONS
-- ===========================

-- Book sales ranking within each category
SELECT 
    b.title,
    c.category_name,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.price,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    RANK() OVER (
        PARTITION BY c.category_name 
        ORDER BY COALESCE(SUM(oi.quantity), 0) DESC
    ) as category_sales_rank,
    ROW_NUMBER() OVER (
        ORDER BY COALESCE(SUM(oi.quantity), 0) DESC
    ) as overall_sales_rank
FROM books b
JOIN categories c ON b.category_id = c.category_id
JOIN authors a ON b.author_id = a.author_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_status != 'Cancelled'
GROUP BY b.book_id
ORDER BY c.category_name, category_sales_rank;

-- Customer spending trends with running totals
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total,
    LAG(o.total_amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date
    ) as previous_order_amount,
    LEAD(o.total_amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date
    ) as next_order_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
ORDER BY c.customer_id, o.order_date;

-- ===========================
-- 5. CORRELATED SUBQUERIES
-- ===========================

-- Authors with their most expensive book
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    a.nationality,
    (SELECT b.title 
     FROM books b 
     WHERE b.author_id = a.author_id 
     ORDER BY b.price DESC 
     LIMIT 1) as most_expensive_book,
    (SELECT MAX(b.price) 
     FROM books b 
     WHERE b.author_id = a.author_id) as highest_price
FROM authors a
WHERE EXISTS (
    SELECT 1 FROM books b WHERE b.author_id = a.author_id
)
ORDER BY highest_price DESC;

-- Customers with their favorite genre
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.membership_level,
    (SELECT cat.category_name
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.order_id
     JOIN books b ON oi.book_id = b.book_id
     JOIN categories cat ON b.category_id = cat.category_id
     WHERE o.customer_id = c.customer_id
     GROUP BY cat.category_id
     ORDER BY SUM(oi.quantity) DESC
     LIMIT 1) as favorite_genre,
    (SELECT COUNT(DISTINCT o.order_id)
     FROM orders o
     WHERE o.customer_id = c.customer_id
     AND o.order_status != 'Cancelled') as total_orders
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.customer_id = c.customer_id 
    AND o.order_status != 'Cancelled'
)
ORDER BY total_orders DESC;

-- ===========================
-- 6. SET OPERATIONS
-- ===========================

-- All customers who have either reviewed books or placed orders
SELECT DISTINCT
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    'Has Orders' as activity_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'

UNION

SELECT DISTINCT
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    'Has Reviews' as activity_type
FROM customers c
JOIN reviews r ON c.customer_id = r.customer_id

ORDER BY customer_name;

-- Books available in inventory vs books that have been ordered
SELECT 
    b.title,
    'In Inventory' as status,
    i.quantity_in_stock as quantity
FROM books b
JOIN inventory i ON b.book_id = i.book_id
WHERE i.quantity_in_stock > 0

INTERSECT

SELECT 
    b.title,
    'Has Orders' as status,
    COUNT(oi.order_item_id) as quantity
FROM books b
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY b.book_id, b.title;

-- ===========================
-- 7. ADVANCED AGGREGATIONS
-- ===========================

-- Monthly sales summary with multiple metrics
SELECT 
    YEAR(o.order_date) as year,
    MONTH(o.order_date) as month,
    MONTHNAME(o.order_date) as month_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_units_sold,
    COUNT(DISTINCT oi.book_id) as unique_books_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year DESC, month DESC;

-- Publisher performance comparison
SELECT 
    p.publisher_name,
    COUNT(DISTINCT b.book_id) as books_published,
    COALESCE(SUM(oi.quantity), 0) as total_units_sold,
    COALESCE(SUM(oi.total_price), 0) as total_revenue,
    ROUND(COALESCE(AVG(r.rating), 0), 2) as avg_rating,
    COUNT(DISTINCT r.review_id) as total_reviews
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY p.publisher_id
ORDER BY total_revenue DESC;

-- ===========================
-- 8. COMPLEX BUSINESS QUERIES
-- ===========================

-- Customer lifetime value analysis
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.membership_level,
        c.registration_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MIN(o.order_date) as first_order,
        MAX(o.order_date) as last_order,
        DATEDIFF(CURDATE(), c.registration_date) as days_since_registration
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id 
        AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id
)
SELECT 
    customer_name,
    membership_level,
    total_orders,
    total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    days_since_registration,
    CASE 
        WHEN days_since_registration > 0 THEN 
            ROUND(total_spent / (days_since_registration / 365.0), 2)
        ELSE 0
    END as annual_value,
    CASE 
        WHEN total_orders > 5 AND total_spent > 100 THEN 'VIP'
        WHEN total_orders > 3 AND total_spent > 50 THEN 'Loyal'
        WHEN total_orders > 1 THEN 'Regular'
        WHEN total_orders = 1 THEN 'New'
        ELSE 'Inactive'
    END as customer_segment
FROM customer_metrics
ORDER BY total_spent DESC;

-- Inventory optimization report
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    c.category_name,
    i.quantity_in_stock,
    i.reorder_level,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'REORDER NOW'
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 'LOW STOCK'
        ELSE 'ADEQUATE'
    END as stock_status,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'NO SALES'
        WHEN COALESCE(SUM(oi.quantity), 0) < 3 THEN 'SLOW MOVING'
        WHEN COALESCE(SUM(oi.quantity), 0) < 10 THEN 'MODERATE'
        ELSE 'FAST MOVING'
    END as sales_velocity
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
JOIN inventory i ON b.book_id = i.book_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY b.book_id
ORDER BY 
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 1
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 2
        ELSE 3
    END,
    total_sold DESC;
