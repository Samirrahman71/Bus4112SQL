-- =========================================
-- SQL BOOKSTORE PROJECT - ANALYTICS QUERIES
-- =========================================
-- This file demonstrates business intelligence and analytical SQL queries
-- Skills: Advanced analytics, KPI calculations, trend analysis, cohort analysis

-- ===========================
-- 1. SALES PERFORMANCE ANALYTICS
-- ===========================

-- Monthly sales trends with growth rates
WITH monthly_sales AS (
    SELECT 
        YEAR(o.order_date) as year,
        MONTH(o.order_date) as month,
        COUNT(DISTINCT o.order_id) as orders,
        SUM(o.total_amount) as revenue,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        SUM(oi.quantity) as units_sold
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
),
sales_with_previous AS (
    SELECT 
        year,
        month,
        orders,
        revenue,
        unique_customers,
        units_sold,
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
    units_sold,
    ROUND(revenue / orders, 2) as avg_order_value,
    CASE 
        WHEN prev_month_revenue IS NOT NULL THEN 
            ROUND(((revenue - prev_month_revenue) / prev_month_revenue) * 100, 2)
        ELSE NULL
    END as revenue_growth_percent,
    CASE 
        WHEN prev_month_orders IS NOT NULL THEN 
            ROUND(((orders - prev_month_orders) / prev_month_orders) * 100, 2)
        ELSE NULL
    END as order_growth_percent
FROM sales_with_previous
ORDER BY year, month;

-- ===========================
-- 2. CUSTOMER ANALYTICS
-- ===========================

-- Customer segmentation using RFM analysis (Recency, Frequency, Monetary)
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.membership_level,
        DATEDIFF(CURDATE(), MAX(o.order_date)) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        SUM(o.total_amount) as monetary_value,
        AVG(o.total_amount) as avg_order_value
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
    membership_level,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) as total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    recency_score,
    frequency_score,
    monetary_score,
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

-- Customer cohort analysis by registration month
WITH customer_cohorts AS (
    SELECT 
        c.customer_id,
        DATE_FORMAT(c.registration_date, '%Y-%m') as cohort_month,
        MIN(DATE_FORMAT(o.order_date, '%Y-%m')) as first_order_month
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id 
        AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id, cohort_month
),
cohort_periods AS (
    SELECT 
        cohort_month,
        first_order_month,
        COUNT(DISTINCT customer_id) as customers,
        CASE 
            WHEN first_order_month IS NULL THEN NULL
            ELSE PERIOD_DIFF(
                CAST(REPLACE(first_order_month, '-', '') AS UNSIGNED),
                CAST(REPLACE(cohort_month, '-', '') AS UNSIGNED)
            )
        END as period_number
    FROM customer_cohorts
    GROUP BY cohort_month, first_order_month
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) as cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)
SELECT 
    cp.cohort_month,
    cs.cohort_size,
    cp.period_number,
    cp.customers,
    ROUND((cp.customers * 100.0 / cs.cohort_size), 2) as retention_rate
FROM cohort_periods cp
JOIN cohort_sizes cs ON cp.cohort_month = cs.cohort_month
WHERE cp.period_number IS NOT NULL
ORDER BY cp.cohort_month, cp.period_number;

-- ===========================
-- 3. PRODUCT PERFORMANCE ANALYTICS
-- ===========================

-- Best and worst performing books
WITH book_performance AS (
    SELECT 
        b.book_id,
        b.title,
        CONCAT(a.first_name, ' ', a.last_name) as author,
        c.category_name,
        b.price,
        COALESCE(SUM(oi.quantity), 0) as units_sold,
        COALESCE(SUM(oi.total_price), 0) as revenue,
        COALESCE(AVG(r.rating), 0) as avg_rating,
        COUNT(DISTINCT r.review_id) as review_count,
        b.price * COALESCE(SUM(oi.quantity), 0) as potential_revenue
    FROM books b
    JOIN authors a ON b.author_id = a.author_id
    JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id 
        AND o.order_status != 'Cancelled'
    LEFT JOIN reviews r ON b.book_id = r.book_id
    GROUP BY b.book_id
),
performance_ranked AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY revenue DESC) as revenue_rank,
        RANK() OVER (ORDER BY units_sold DESC) as sales_rank,
        RANK() OVER (ORDER BY avg_rating DESC) as rating_rank
    FROM book_performance
)
SELECT 
    title,
    author,
    category_name,
    ROUND(price, 2) as price,
    units_sold,
    ROUND(revenue, 2) as revenue,
    ROUND(avg_rating, 2) as avg_rating,
    review_count,
    revenue_rank,
    sales_rank,
    rating_rank,
    CASE 
        WHEN revenue_rank <= 5 THEN 'Top Performer'
        WHEN revenue_rank <= 10 THEN 'Good Performer'
        WHEN units_sold = 0 THEN 'No Sales'
        ELSE 'Average Performer'
    END as performance_category
FROM performance_ranked
ORDER BY revenue_rank;

-- Category performance deep dive
WITH category_metrics AS (
    SELECT 
        c.category_name,
        COUNT(DISTINCT b.book_id) as total_books,
        COUNT(DISTINCT CASE WHEN oi.book_id IS NOT NULL THEN b.book_id END) as books_with_sales,
        COALESCE(SUM(oi.quantity), 0) as total_units_sold,
        COALESCE(SUM(oi.total_price), 0) as total_revenue,
        COALESCE(AVG(b.price), 0) as avg_book_price,
        COALESCE(AVG(r.rating), 0) as avg_category_rating,
        COUNT(DISTINCT r.review_id) as total_reviews
    FROM categories c
    LEFT JOIN books b ON c.category_id = b.category_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id 
        AND o.order_status != 'Cancelled'
    LEFT JOIN reviews r ON b.book_id = r.book_id
    GROUP BY c.category_id, c.category_name
)
SELECT 
    category_name,
    total_books,
    books_with_sales,
    ROUND((books_with_sales * 100.0 / NULLIF(total_books, 0)), 2) as sales_penetration_percent,
    total_units_sold,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_book_price, 2) as avg_book_price,
    ROUND(avg_category_rating, 2) as avg_rating,
    total_reviews,
    CASE 
        WHEN total_units_sold > 0 THEN ROUND(total_revenue / total_units_sold, 2)
        ELSE 0
    END as avg_selling_price,
    CASE 
        WHEN total_revenue > 200 THEN 'High Revenue'
        WHEN total_revenue > 100 THEN 'Medium Revenue'
        WHEN total_revenue > 0 THEN 'Low Revenue'
        ELSE 'No Revenue'
    END as revenue_tier
FROM category_metrics
ORDER BY total_revenue DESC;

-- ===========================
-- 4. INVENTORY ANALYTICS
-- ===========================

-- Inventory turnover analysis
WITH inventory_analysis AS (
    SELECT 
        b.book_id,
        b.title,
        CONCAT(a.first_name, ' ', a.last_name) as author,
        c.category_name,
        i.quantity_in_stock,
        i.reorder_level,
        i.max_stock_level,
        COALESCE(SUM(oi.quantity), 0) as total_sold,
        DATEDIFF(CURDATE(), COALESCE(i.last_restocked_date, b.created_at)) as days_since_restock
    FROM books b
    JOIN authors a ON b.author_id = a.author_id
    JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN inventory i ON b.book_id = i.book_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id 
        AND o.order_status != 'Cancelled'
    GROUP BY b.book_id
)
SELECT 
    title,
    author,
    category_name,
    quantity_in_stock,
    reorder_level,
    total_sold,
    days_since_restock,
    CASE 
        WHEN days_since_restock > 0 AND total_sold > 0 THEN 
            ROUND(total_sold / (days_since_restock / 30.0), 2)
        ELSE 0
    END as monthly_sales_rate,
    CASE 
        WHEN quantity_in_stock > 0 AND total_sold > 0 THEN 
            ROUND(quantity_in_stock / (total_sold / (days_since_restock / 30.0)), 1)
        ELSE NULL
    END as months_of_stock,
    CASE 
        WHEN quantity_in_stock <= reorder_level THEN 'CRITICAL - REORDER NOW'
        WHEN quantity_in_stock <= reorder_level * 1.5 THEN 'LOW - Monitor Closely'
        WHEN total_sold = 0 THEN 'OVERSTOCK - No Sales'
        ELSE 'ADEQUATE'
    END as stock_status,
    CASE 
        WHEN total_sold = 0 THEN 'Dead Stock'
        WHEN total_sold / GREATEST(days_since_restock / 30.0, 1) > 10 THEN 'Fast Moving'
        WHEN total_sold / GREATEST(days_since_restock / 30.0, 1) > 3 THEN 'Medium Moving'
        ELSE 'Slow Moving'
    END as movement_category
FROM inventory_analysis
ORDER BY 
    CASE 
        WHEN quantity_in_stock <= reorder_level THEN 1
        WHEN quantity_in_stock <= reorder_level * 1.5 THEN 2
        WHEN total_sold = 0 THEN 3
        ELSE 4
    END,
    total_sold DESC;

-- ===========================
-- 5. PROFITABILITY ANALYSIS
-- ===========================

-- Book profitability analysis
WITH book_profitability AS (
    SELECT 
        b.book_id,
        b.title,
        CONCAT(a.first_name, ' ', a.last_name) as author,
        c.category_name,
        b.price,
        COALESCE(b.cost, b.price * 0.6) as estimated_cost, -- Assume 60% cost if not specified
        COALESCE(SUM(oi.quantity), 0) as units_sold,
        COALESCE(SUM(oi.total_price), 0) as revenue,
        COALESCE(SUM(oi.quantity * COALESCE(b.cost, b.price * 0.6)), 0) as total_cost
    FROM books b
    JOIN authors a ON b.author_id = a.author_id
    JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id 
        AND o.order_status != 'Cancelled'
    GROUP BY b.book_id
)
SELECT 
    title,
    author,
    category_name,
    ROUND(price, 2) as selling_price,
    ROUND(estimated_cost, 2) as cost_per_unit,
    ROUND(price - estimated_cost, 2) as profit_per_unit,
    ROUND(((price - estimated_cost) / price) * 100, 2) as profit_margin_percent,
    units_sold,
    ROUND(revenue, 2) as total_revenue,
    ROUND(total_cost, 2) as total_cost,
    ROUND(revenue - total_cost, 2) as total_profit,
    CASE 
        WHEN units_sold > 0 THEN ROUND((revenue - total_cost) / units_sold, 2)
        ELSE 0
    END as profit_per_unit_sold,
    CASE 
        WHEN revenue > 0 THEN ROUND(((revenue - total_cost) / revenue) * 100, 2)
        ELSE 0
    END as actual_profit_margin_percent
FROM book_profitability
WHERE units_sold > 0
ORDER BY total_profit DESC;

-- ===========================
-- 6. CUSTOMER LIFETIME VALUE
-- ===========================

-- Detailed customer lifetime value calculation
WITH customer_ltv AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.membership_level,
        c.registration_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MIN(o.order_date) as first_purchase,
        MAX(o.order_date) as last_purchase,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) as customer_lifespan_days,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) > 1 THEN 
                DATEDIFF(MAX(o.order_date), MIN(o.order_date)) / (COUNT(DISTINCT o.order_id) - 1)
            ELSE NULL
        END as avg_days_between_orders
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id
),
ltv_calculations AS (
    SELECT 
        *,
        CASE 
            WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders > 0 THEN
                365.0 / avg_days_between_orders
            ELSE 1
        END as estimated_annual_orders,
        CASE 
            WHEN customer_lifespan_days > 0 THEN
                total_spent / (customer_lifespan_days / 365.0)
            ELSE total_spent
        END as annual_value
    FROM customer_ltv
)
SELECT 
    customer_name,
    membership_level,
    total_orders,
    ROUND(total_spent, 2) as total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    customer_lifespan_days,
    avg_days_between_orders,
    ROUND(estimated_annual_orders, 2) as est_annual_orders,
    ROUND(annual_value, 2) as annual_value,
    ROUND(estimated_annual_orders * avg_order_value, 2) as predicted_annual_value,
    CASE 
        WHEN total_spent > 200 THEN 'High Value'
        WHEN total_spent > 100 THEN 'Medium Value'
        WHEN total_spent > 50 THEN 'Low Value'
        ELSE 'Minimal Value'
    END as customer_value_tier,
    CASE 
        WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders <= 30 THEN 'Very Active'
        WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders <= 60 THEN 'Active'
        WHEN avg_days_between_orders IS NOT NULL AND avg_days_between_orders <= 120 THEN 'Moderate'
        ELSE 'Inactive'
    END as purchase_frequency_tier
FROM ltv_calculations
ORDER BY total_spent DESC;

-- ===========================
-- 7. TREND ANALYSIS
-- ===========================

-- Daily sales trends with moving averages
SELECT 
    DATE(o.order_date) as order_date,
    COUNT(DISTINCT o.order_id) as daily_orders,
    SUM(o.total_amount) as daily_revenue,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    AVG(COUNT(DISTINCT o.order_id)) OVER (
        ORDER BY DATE(o.order_date) 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as orders_7day_avg,
    AVG(SUM(o.total_amount)) OVER (
        ORDER BY DATE(o.order_date) 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as revenue_7day_avg,
    DAYNAME(o.order_date) as day_of_week
FROM orders o
WHERE o.order_status != 'Cancelled'
GROUP BY DATE(o.order_date)
ORDER BY order_date DESC;

-- ===========================
-- 8. COMPETITIVE ANALYSIS
-- ===========================

-- Publisher market share analysis
WITH publisher_market_share AS (
    SELECT 
        p.publisher_name,
        COUNT(DISTINCT b.book_id) as books_published,
        COALESCE(SUM(oi.quantity), 0) as total_units_sold,
        COALESCE(SUM(oi.total_price), 0) as total_revenue,
        COALESCE(AVG(r.rating), 0) as avg_rating
    FROM publishers p
    LEFT JOIN books b ON p.publisher_id = b.publisher_id
    LEFT JOIN order_items oi ON b.book_id = oi.book_id
    LEFT JOIN orders o ON oi.order_id = o.order_id 
        AND o.order_status != 'Cancelled'
    LEFT JOIN reviews r ON b.book_id = r.book_id
    GROUP BY p.publisher_id
),
market_totals AS (
    SELECT 
        SUM(total_units_sold) as market_total_units,
        SUM(total_revenue) as market_total_revenue
    FROM publisher_market_share
)
SELECT 
    pms.publisher_name,
    pms.books_published,
    pms.total_units_sold,
    ROUND(pms.total_revenue, 2) as total_revenue,
    ROUND(pms.avg_rating, 2) as avg_rating,
    ROUND((pms.total_units_sold * 100.0 / NULLIF(mt.market_total_units, 0)), 2) as unit_market_share_percent,
    ROUND((pms.total_revenue * 100.0 / NULLIF(mt.market_total_revenue, 0)), 2) as revenue_market_share_percent,
    CASE 
        WHEN pms.total_revenue > mt.market_total_revenue * 0.25 THEN 'Market Leader'
        WHEN pms.total_revenue > mt.market_total_revenue * 0.10 THEN 'Major Player'
        WHEN pms.total_revenue > mt.market_total_revenue * 0.05 THEN 'Significant Player'
        WHEN pms.total_revenue > 0 THEN 'Minor Player'
        ELSE 'No Sales'
    END as market_position
FROM publisher_market_share pms
CROSS JOIN market_totals mt
ORDER BY pms.total_revenue DESC;
