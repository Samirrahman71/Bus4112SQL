# SQL Bookstore Database Project

![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Oracle](https://img.shields.io/badge/Oracle-19c+-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-Integration-000000?style=for-the-badge&logo=json&logoColor=white)
![Performance](https://img.shields.io/badge/Performance-Optimized-00D084?style=for-the-badge&logo=speedtest&logoColor=white)

## A Real-World E-commerce Database System

This project started as a class assignment for Bus4112, but I ended up going way beyond the requirements because I genuinely enjoy working with databases. What began as a simple bookstore schema evolved into a comprehensive e-commerce system that demonstrates the kind of SQL work I'd actually want to do in a production environment.

## What This Project Demonstrates

I built this to show I can handle everything from basic database design to complex analytical queries. If you're evaluating SQL skills for a role, this project covers:

- **Database Architecture**: Properly normalized schema with realistic business relationships
- **Advanced SQL**: Complex queries that actually solve business problems
- **Performance Optimization**: Indexing strategies and query tuning 
- **Analytics**: Customer segmentation, sales analysis, and business intelligence
- **Multi-Platform**: Both MySQL and Oracle implementations

## The Database Design

I designed this around a realistic bookstore/e-commerce scenario with 9 interconnected tables:

```
Authors ←→ Books ←→ Categories
    ↓        ↓
Publishers  Orders ← Customers
    ↓        ↓
Inventory   Reviews
```

The schema handles complex scenarios like:
- Books with multiple authors (many-to-many relationship)
- Customer order history and loyalty tracking
- Inventory management with reorder alerts
- Review system tied to verified purchases

## Real-World SQL Problems I Solved

### Customer Lifetime Value Analysis
Instead of just basic SELECTs, I wrote queries that actually help businesses make decisions:

```sql
-- RFM Customer Segmentation (the kind of analysis marketing teams actually need)
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    CASE 
        WHEN days_since_last_order <= 30 AND total_orders >= 5 THEN 'Champions'
        WHEN days_since_last_order <= 60 AND total_orders >= 3 THEN 'Loyal'
        WHEN days_since_last_order <= 30 AND total_orders < 3 THEN 'Potential'
        ELSE 'At Risk'
    END as segment
FROM customer_metrics;
```

### Sales Trend Analysis
I also built queries that track business performance over time:

```sql
-- Month-over-month growth analysis with moving averages
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') as month,
    SUM(total_amount) as revenue,
    ROUND(((SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))) 
           / LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))) * 100, 2) as growth_rate
FROM orders 
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
```

## Project Structure

I organized everything logically so you can follow my progression from basic to advanced:

```
├── 1_schema_creation.sql      # Database setup with proper constraints
├── 2_sample_data.sql          # Realistic test data (not just "John Doe" entries)
├── 3_basic_queries.sql        # Foundation - SELECTs, JOINs, GROUP BY
├── 4_complex_queries.sql      # Advanced JOINs, subqueries, CTEs
├── 5_analytics_queries.sql    # Business intelligence and reporting
├── 6_views_procedures.sql     # Stored procedures and automation
├── 7_performance_indexes.sql  # Query optimization and indexing
└── bookstore_queries.sql      # Everything combined for easy testing
```

## Oracle Version (Because Real Companies Use Oracle)

Since many enterprises use Oracle, I converted everything to Oracle syntax as well:

- `oracle_1_schema_creation.sql` - Schema with sequences and triggers
- `oracle_2_sample_data.sql` - Oracle-compatible data loading
- `oracle_queries.sql` - Advanced Oracle features like hierarchical queries

The Oracle version uses features like `LISTAGG`, `CONNECT BY`, and analytical functions that you'd actually encounter in enterprise environments.

## Performance Considerations

I didn't just write queries - I made sure they'd actually perform well:

- **Composite indexes** on frequently queried columns
- **Covering indexes** to avoid table lookups
- **Query optimization** with execution plan analysis
- **Proper WHERE clause ordering** for index usage

For example, this index dramatically improves order lookup performance:
```sql
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);
```

## Business Intelligence Features

The analytics queries solve real business problems:

- **Customer Segmentation**: RFM analysis to identify high-value customers
- **Inventory Management**: Automatic reorder point calculations
- **Sales Analysis**: Trend identification and seasonality analysis
- **Performance Metrics**: Book popularity and publisher performance

## What I Learned Building This

This project taught me that good database work isn't just about writing syntactically correct SQL - it's about:

1. **Understanding the business context** behind each query
2. **Designing for performance** from the start, not as an afterthought
3. **Creating maintainable code** that other developers can understand
4. **Thinking about data integrity** and what could go wrong
5. **Building analytics that actually help make decisions**

## Modern Features & Advanced SQL

Beyond the basics, I added some really cool modern database features that showcase advanced SQL skills:

 

### 🔥 **JSON Integration**

 

- Added flexible JSON metadata fields to books
- Store dynamic attributes like genres, awards, themes, reading levels
- Query JSON data with native SQL functions
- Perfect for modern applications that need schema flexibility

 

### 🔍 **Full-Text Search**

 

- Implemented advanced search capabilities
- Search across titles, descriptions, and author biographies
- Relevance scoring and natural language queries
- Much better than basic LIKE queries

 

### 📊 **Real-Time Analytics Dashboard**

 

- Live KPI queries (daily sales, top performers, inventory alerts)
- Customer activity heatmaps by hour
- Sales velocity analysis
- Customer lifetime value predictions
- All optimized for sub-second performance

 

### 🎯 **Advanced Window Functions**

 

- Running totals and moving averages
- Customer ranking and quartile analysis
- Day-over-day sales comparisons
- Pivot tables for cross-tabulation

 

### ✅ **Data Quality Validation**

 

- Automated data integrity checks
- Email format validation with regex
- Orphaned record detection
- Performance monitoring queries

 

These features demonstrate real-world database skills that go way beyond basic CRUD operations—the kind of stuff you'd actually build in a production environment.

## Technical Details

**Database Systems**: MySQL 8.0+ and Oracle 19c+
**Key Features**: 
- Full ACID compliance
- Referential integrity with foreign keys
- Trigger-based automation
- Comprehensive indexing strategy

**Performance**: Optimized for sub-second response times on complex analytical queries

## Getting Started

If you want to run this yourself:

```bash
# Clone and setup
git clone https://github.com/Samirrahman71/Bus4112SQL.git
cd Bus4112SQL

# MySQL setup
mysql -u root -p < 1_schema_creation.sql
mysql -u root -p < 2_sample_data.sql

# Now you can run any of the query files
mysql -u root -p < bookstore_queries.sql
```

For Oracle, just copy the oracle_*.sql files into Oracle Live SQL and run them in order.

## Why This Matters

I built this project because I wanted to show I can do more than just basic CRUD operations. In real database work, you're solving business problems, optimizing performance, and building systems that can scale. This project demonstrates that I think about databases the way they're actually used in production environments.

Whether you're looking at this for academic purposes or evaluating technical skills, I hope it shows that I understand both the technical and business sides of database development.
