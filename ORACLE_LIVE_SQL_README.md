# SQL Bookstore Project - Oracle Live SQL Integration

## 🚀 Quick Start for Oracle Live SQL

This project has been specifically adapted for **Oracle Live SQL** with all the necessary syntax conversions and Oracle-specific features.

### 📋 Prerequisites
- Access to [Oracle Live SQL](https://livesql.oracle.com/) (free Oracle account required)
- No additional software installation needed

### 🎯 Execution Order

**IMPORTANT**: Execute these files in the exact order listed below:

1. **`oracle_1_schema_creation.sql`** - Creates database schema with Oracle-specific syntax
2. **`oracle_2_sample_data.sql`** - Inserts realistic sample data
3. **`oracle_queries.sql`** - Demonstrates comprehensive SQL queries

---

## 📁 Oracle Live SQL File Structure

### Core Oracle Files
- `oracle_1_schema_creation.sql` - Oracle schema creation
- `oracle_2_sample_data.sql` - Oracle sample data insertion  
- `oracle_queries.sql` - Oracle-optimized queries

### Original MySQL Files (for reference)
- `1_schema_creation.sql` - Original MySQL version
- `2_sample_data.sql` - Original MySQL version
- `bookstore_queries.sql` - Original MySQL version

---

## 🔄 Key Oracle Adaptations Made

### Syntax Conversions
| MySQL Feature | Oracle Equivalent |
|---------------|-------------------|
| `AUTO_INCREMENT` | `SEQUENCE` + `TRIGGER` |
| `VARCHAR(n)` | `VARCHAR2(n)` |
| `ENUM` | `CHECK` constraints |
| `LIMIT` | `ROWNUM` or `FETCH FIRST` |
| `CONCAT()` | `||` operator |
| `IFNULL()` | `NVL()` |
| `NOW()` | `SYSDATE` |

### Oracle-Specific Features Added
- ✅ **Sequences** for auto-incrementing primary keys
- ✅ **Triggers** for automatic ID generation and timestamps
- ✅ **Advanced Analytics** (RANK, DENSE_RANK, NTILE, etc.)
- ✅ **Hierarchical Queries** (CONNECT BY)
- ✅ **PIVOT/UNPIVOT** operations
- ✅ **Regular Expressions** (REGEXP_LIKE)
- ✅ **String Aggregation** (LISTAGG)
- ✅ **Window Functions** with Oracle syntax
- ✅ **ROLLUP/CUBE** for reporting

---

## 🎮 How to Use in Oracle Live SQL

### Step 1: Access Oracle Live SQL
1. Go to [https://livesql.oracle.com/](https://livesql.oracle.com/)
2. Sign in with your Oracle account (create free account if needed)
3. Click "Run SQL" to open the SQL worksheet

### Step 2: Execute Schema Creation
1. Copy contents of `oracle_1_schema_creation.sql`
2. Paste into Oracle Live SQL worksheet
3. Click "Run" (green play button)
4. Wait for "Schema Created Successfully!" message

### Step 3: Load Sample Data
1. Clear the worksheet
2. Copy contents of `oracle_2_sample_data.sql`
3. Paste and run
4. Verify data loading with the verification queries included

### Step 4: Explore Queries
1. Copy sections from `oracle_queries.sql`
2. Run individual queries or sections
3. Experiment with modifications

---

## 📊 Database Schema Overview

### Core Tables (9 total)
```
AUTHORS (8 records) → stores author information
├── PUBLISHERS (6 records) → publishing companies
├── CATEGORIES (10 records) → book categories with hierarchy
├── BOOKS (10 records) → main book catalog
├── CUSTOMERS (8 records) → customer information
├── ORDERS (8 records) → order transactions
├── ORDER_ITEMS (10 records) → individual order line items
├── REVIEWS (10 records) → customer book reviews
├── INVENTORY (10 records) → stock management
└── BOOK_AUTHORS (10 records) → many-to-many author relationships
```

### Key Relationships
- Books ↔ Authors (many-to-many via BOOK_AUTHORS)
- Books → Publishers, Categories (many-to-one)
- Orders → Customers (many-to-one)
- Order Items → Orders, Books (many-to-one)
- Reviews → Books, Customers (many-to-one)

---

## 🎯 SQL Skills Demonstrated

### Beginner Level
- ✅ Basic SELECT statements
- ✅ WHERE clauses and filtering
- ✅ ORDER BY and sorting
- ✅ Aggregate functions (COUNT, SUM, AVG)
- ✅ GROUP BY and HAVING
- ✅ Basic JOINs

### Intermediate Level
- ✅ Complex multi-table JOINs
- ✅ Subqueries (correlated and non-correlated)
- ✅ CASE statements
- ✅ Date/time functions
- ✅ String manipulation
- ✅ NULL handling

### Advanced Level
- ✅ Window functions (RANK, ROW_NUMBER, NTILE)
- ✅ Common Table Expressions (WITH clause)
- ✅ Analytical functions (LAG, LEAD, FIRST_VALUE)
- ✅ Hierarchical queries (CONNECT BY)
- ✅ PIVOT/UNPIVOT operations
- ✅ Regular expressions
- ✅ Advanced aggregations (ROLLUP, CUBE)
- ✅ Performance optimization

---

## 🔍 Sample Query Categories

### Business Intelligence Queries
- Sales performance analysis
- Customer segmentation (RFM analysis)
- Inventory management reports
- Revenue trend analysis
- Product performance metrics

### Advanced Analytics
- Moving averages
- Percentile calculations
- Cohort analysis
- Market share analysis
- Customer lifetime value

### Reporting Queries
- Executive dashboards
- Operational reports
- Inventory status reports
- Financial summaries
- Performance metrics

---

## 💡 Oracle Live SQL Tips

### Performance Optimization
- Use `ROWNUM` for limiting results: `WHERE ROWNUM <= 10`
- Leverage Oracle's cost-based optimizer
- Use `EXPLAIN PLAN` for query analysis
- Take advantage of Oracle's built-in functions

### Best Practices
- Always use sequences for primary keys
- Implement proper indexing strategies
- Use bind variables for repeated queries
- Leverage Oracle's analytical functions
- Use CTEs for complex logic breakdown

### Oracle-Specific Features to Explore
```sql
-- Hierarchical queries
SELECT * FROM categories
START WITH parent_category_id IS NULL
CONNECT BY PRIOR category_id = parent_category_id;

-- Analytical functions
SELECT title, price,
       RANK() OVER (ORDER BY price DESC) as price_rank
FROM books;

-- String aggregation
SELECT category_name,
       LISTAGG(title, ', ') WITHIN GROUP (ORDER BY title)
FROM books b JOIN categories c ON b.category_id = c.category_id
GROUP BY category_name;
```

---

## 🚀 Getting Started Commands

```sql
-- 1. Verify schema creation
SELECT table_name FROM user_tables ORDER BY table_name;

-- 2. Check data loading
SELECT 'AUTHORS' as table_name, COUNT(*) as records FROM authors
UNION ALL
SELECT 'BOOKS', COUNT(*) FROM books
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM customers;

-- 3. Run a sample query
SELECT b.title, a.first_name || ' ' || a.last_name as author, b.price
FROM books b
JOIN authors a ON b.author_id = a.author_id
ORDER BY b.price DESC;
```

---

## 🎓 Academic Usage

This project is perfect for:
- **Database Management courses** (Bus4112, etc.)
- **SQL proficiency demonstrations**
- **Data analysis projects**
- **Business intelligence assignments**
- **Advanced database concepts**

The Oracle version showcases:
- Industry-standard Oracle syntax
- Enterprise-level database features
- Advanced analytical capabilities
- Professional database design patterns

---

## 🔧 Troubleshooting

### Common Issues
1. **Sequence already exists**: The schema creation handles this automatically
2. **Table already exists**: Drop tables section handles cleanup
3. **Data type errors**: All Oracle data types are properly specified
4. **Date format issues**: Uses Oracle DATE literals (DATE '2024-01-15')

### Support Resources
- [Oracle Live SQL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
- [Oracle SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- Oracle Live SQL community forums

---

## ✅ Success Verification

After running all scripts, you should see:
- ✅ 9 tables created successfully
- ✅ 9 sequences created and functioning
- ✅ Sample data loaded (80+ records total)
- ✅ All queries executing without errors
- ✅ Realistic business data for analysis

**Ready to showcase your Oracle SQL expertise!** 🎉
