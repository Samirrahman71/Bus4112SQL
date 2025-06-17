# SQL Bookstore Project

A comprehensive SQL database project demonstrating proficiency in database design, complex queries, and advanced SQL features.

## Project Overview

This project implements a complete bookstore database system with:
- **Multiple related tables** with proper relationships
- **Sample data** for realistic testing scenarios  
- **Complex SQL queries** showcasing various SQL operations
- **Views and stored procedures** for advanced functionality
- **Performance optimization** with indexes

## Database Schema

### Core Tables
- `authors` - Author information
- `publishers` - Publisher details
- `categories` - Book categories
- `books` - Main book catalog
- `customers` - Customer information
- `orders` - Purchase orders
- `order_items` - Individual items in orders
- `reviews` - Customer book reviews
- `inventory` - Stock management

### Key Features Demonstrated
- ✅ **Primary and Foreign Keys**
- ✅ **One-to-Many and Many-to-Many relationships**
- ✅ **Complex JOINs** (INNER, LEFT, RIGHT, FULL OUTER)
- ✅ **Subqueries and CTEs**
- ✅ **Aggregate functions** and GROUP BY
- ✅ **Window functions**
- ✅ **Views and stored procedures**
- ✅ **Triggers and constraints**
- ✅ **Indexes for performance**

## Files Structure

```
├── 1_schema_creation.sql     # Database and table creation
├── 2_sample_data.sql         # Insert sample data
├── 3_basic_queries.sql       # Basic SELECT operations
├── 4_complex_queries.sql     # Advanced queries with JOINs
├── 5_analytics_queries.sql   # Business intelligence queries
├── 6_views_procedures.sql    # Views and stored procedures
├── 7_performance_indexes.sql # Index creation and optimization
└── bookstore_queries.sql     # All queries combined
```

## How to Use

1. **Setup**: Run `1_schema_creation.sql` to create the database schema
2. **Data**: Execute `2_sample_data.sql` to populate with sample data
3. **Practice**: Use the query files to explore different SQL concepts
4. **Test**: Run `bookstore_queries.sql` for a complete demonstration

## Skills Demonstrated

This project showcases proficiency in:
- Database design and normalization
- Complex query writing and optimization  
- Data analysis and reporting
- Advanced SQL features and best practices
