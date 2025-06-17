-- =========================================
-- SQL BOOKSTORE PROJECT - VIEWS & PROCEDURES
-- =========================================
-- This file demonstrates advanced SQL features: Views, Stored Procedures, Functions, Triggers
-- Skills: Database objects creation, business logic implementation, automation

-- ===========================
-- 1. USEFUL VIEWS
-- ===========================

-- Complete book information view
CREATE OR REPLACE VIEW v_book_details AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    a.nationality as author_nationality,
    p.publisher_name,
    c.category_name,
    b.publication_date,
    b.page_count,
    b.language,
    b.price,
    b.description,
    i.quantity_in_stock,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(DISTINCT r.review_id) as review_count,
    COALESCE(SUM(oi.quantity), 0) as total_sold
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN inventory i ON b.book_id = i.book_id
LEFT JOIN reviews r ON b.book_id = r.book_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
GROUP BY b.book_id;

-- Customer summary view
CREATE OR REPLACE VIEW v_customer_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.membership_level,
    c.registration_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order,
    COUNT(DISTINCT r.review_id) as reviews_written
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- Sales performance view
CREATE OR REPLACE VIEW v_sales_performance AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as month_year,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_units_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month_year DESC;

-- Inventory status view
CREATE OR REPLACE VIEW v_inventory_status AS
SELECT 
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    c.category_name,
    i.quantity_in_stock,
    i.reorder_level,
    i.max_stock_level,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'REORDER_REQUIRED'
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 'LOW_STOCK'
        WHEN i.quantity_in_stock >= i.max_stock_level * 0.9 THEN 'OVERSTOCK'
        ELSE 'ADEQUATE'
    END as stock_status,
    i.last_restocked_date,
    DATEDIFF(CURDATE(), i.last_restocked_date) as days_since_restock
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
JOIN inventory i ON b.book_id = i.book_id;

-- Top performers view
CREATE OR REPLACE VIEW v_top_performers AS
SELECT 
    'Book' as type,
    b.title as name,
    CONCAT(a.first_name, ' ', a.last_name) as author_publisher,
    SUM(oi.total_price) as revenue,
    SUM(oi.quantity) as units_sold
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN order_items oi ON b.book_id = oi.book_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY b.book_id
ORDER BY revenue DESC
LIMIT 10;

-- ===========================
-- 2. STORED PROCEDURES
-- ===========================

-- Procedure to add a new book with inventory
DELIMITER //
CREATE PROCEDURE sp_add_new_book(
    IN p_title VARCHAR(200),
    IN p_isbn VARCHAR(20),
    IN p_author_id INT,
    IN p_publisher_id INT,
    IN p_category_id INT,
    IN p_publication_date DATE,
    IN p_page_count INT,
    IN p_language VARCHAR(30),
    IN p_price DECIMAL(10,2),
    IN p_cost DECIMAL(10,2),
    IN p_description TEXT,
    IN p_initial_stock INT,
    IN p_reorder_level INT,
    IN p_max_stock INT
)
BEGIN
    DECLARE book_exists INT DEFAULT 0;
    DECLARE new_book_id INT;
    
    -- Check if book with same ISBN already exists
    SELECT COUNT(*) INTO book_exists 
    FROM books 
    WHERE isbn = p_isbn AND isbn IS NOT NULL;
    
    IF book_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book with this ISBN already exists';
    END IF;
    
    -- Insert the book
    INSERT INTO books (
        title, isbn, author_id, publisher_id, category_id,
        publication_date, page_count, language, price, cost, description
    ) VALUES (
        p_title, p_isbn, p_author_id, p_publisher_id, p_category_id,
        p_publication_date, p_page_count, p_language, p_price, p_cost, p_description
    );
    
    -- Get the new book ID
    SET new_book_id = LAST_INSERT_ID();
    
    -- Add inventory record
    INSERT INTO inventory (
        book_id, quantity_in_stock, reorder_level, max_stock_level, last_restocked_date
    ) VALUES (
        new_book_id, p_initial_stock, p_reorder_level, p_max_stock, CURDATE()
    );
    
    -- Add to book_authors table
    INSERT INTO book_authors (book_id, author_id, author_role)
    VALUES (new_book_id, p_author_id, 'Primary Author');
    
    SELECT CONCAT('Book added successfully with ID: ', new_book_id) as result;
END //
DELIMITER ;

-- Procedure to process customer orders
DELIMITER //
CREATE PROCEDURE sp_process_order(
    IN p_customer_id INT,
    IN p_payment_method VARCHAR(50),
    IN p_shipping_cost DECIMAL(10,2),
    IN p_tax_rate DECIMAL(5,4)
)
BEGIN
    DECLARE order_total DECIMAL(10,2) DEFAULT 0;
    DECLARE tax_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE final_total DECIMAL(10,2) DEFAULT 0;
    DECLARE new_order_id INT;
    
    -- Calculate order totals from temporary cart (assuming cart table exists)
    -- For this example, we'll create a simple version
    
    -- Insert order header
    INSERT INTO orders (
        customer_id, order_status, subtotal, tax_amount, 
        shipping_cost, total_amount, payment_method
    ) VALUES (
        p_customer_id, 'Pending', 0, 0, p_shipping_cost, 0, p_payment_method
    );
    
    SET new_order_id = LAST_INSERT_ID();
    
    SELECT CONCAT('Order created with ID: ', new_order_id) as result;
END //
DELIMITER ;

-- Procedure to update inventory when books are sold
DELIMITER //
CREATE PROCEDURE sp_update_inventory_on_sale(
    IN p_book_id INT,
    IN p_quantity_sold INT
)
BEGIN
    DECLARE current_stock INT DEFAULT 0;
    DECLARE reorder_level INT DEFAULT 0;
    
    -- Get current stock levels
    SELECT quantity_in_stock, reorder_level 
    INTO current_stock, reorder_level
    FROM inventory 
    WHERE book_id = p_book_id;
    
    -- Check if sufficient stock exists
    IF current_stock < p_quantity_sold THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock available';
    END IF;
    
    -- Update inventory
    UPDATE inventory 
    SET quantity_in_stock = quantity_in_stock - p_quantity_sold
    WHERE book_id = p_book_id;
    
    -- Check if reorder is needed
    IF (current_stock - p_quantity_sold) <= reorder_level THEN
        INSERT INTO reorder_notifications (book_id, current_stock, reorder_level, notification_date)
        VALUES (p_book_id, current_stock - p_quantity_sold, reorder_level, NOW())
        ON DUPLICATE KEY UPDATE 
            notification_date = NOW(),
            current_stock = current_stock - p_quantity_sold;
    END IF;
    
    SELECT 'Inventory updated successfully' as result;
END //
DELIMITER ;

-- Procedure to generate sales report
DELIMITER //
CREATE PROCEDURE sp_sales_report(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m-%d') as sale_date,
        COUNT(DISTINCT o.order_id) as orders_count,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as avg_order_value,
        SUM(oi.quantity) as total_units_sold
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN p_start_date AND p_end_date
        AND o.order_status != 'Cancelled'
    GROUP BY DATE(o.order_date)
    ORDER BY sale_date DESC;
END //
DELIMITER ;

-- ===========================
-- 3. STORED FUNCTIONS
-- ===========================

-- Function to calculate customer discount based on membership
DELIMITER //
CREATE FUNCTION fn_calculate_customer_discount(
    p_customer_id INT,
    p_order_amount DECIMAL(10,2)
) RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE membership_level VARCHAR(20);
    DECLARE discount_rate DECIMAL(5,4) DEFAULT 0;
    DECLARE discount_amount DECIMAL(10,2) DEFAULT 0;
    
    -- Get customer membership level
    SELECT membership_level INTO membership_level
    FROM customers 
    WHERE customer_id = p_customer_id;
    
    -- Set discount rate based on membership
    CASE membership_level
        WHEN 'Bronze' THEN SET discount_rate = 0.02;   -- 2%
        WHEN 'Silver' THEN SET discount_rate = 0.05;   -- 5%
        WHEN 'Gold' THEN SET discount_rate = 0.08;     -- 8%
        WHEN 'Platinum' THEN SET discount_rate = 0.12; -- 12%
        ELSE SET discount_rate = 0;
    END CASE;
    
    -- Calculate discount amount
    SET discount_amount = p_order_amount * discount_rate;
    
    RETURN discount_amount;
END //
DELIMITER ;

-- Function to get book availability status
DELIMITER //
CREATE FUNCTION fn_book_availability(p_book_id INT) 
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE stock_qty INT DEFAULT 0;
    DECLARE reorder_qty INT DEFAULT 0;
    DECLARE availability VARCHAR(20);
    
    SELECT quantity_in_stock, reorder_level
    INTO stock_qty, reorder_qty
    FROM inventory
    WHERE book_id = p_book_id;
    
    IF stock_qty IS NULL THEN
        SET availability = 'NOT_TRACKED';
    ELSEIF stock_qty = 0 THEN
        SET availability = 'OUT_OF_STOCK';
    ELSEIF stock_qty <= reorder_qty THEN
        SET availability = 'LOW_STOCK';
    ELSEIF stock_qty > reorder_qty * 2 THEN
        SET availability = 'WELL_STOCKED';
    ELSE
        SET availability = 'AVAILABLE';
    END IF;
    
    RETURN availability;
END //
DELIMITER ;

-- ===========================
-- 4. TRIGGERS
-- ===========================

-- Create reorder notifications table first
CREATE TABLE IF NOT EXISTS reorder_notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    current_stock INT,
    reorder_level INT,
    notification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Ordered', 'Completed') DEFAULT 'Pending',
    UNIQUE KEY unique_book_notification (book_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Trigger to update customer total_spent when order status changes
DELIMITER //
CREATE TRIGGER tr_update_customer_total_after_order
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'Delivered' AND OLD.order_status != 'Delivered' THEN
        UPDATE customers 
        SET total_spent = (
            SELECT COALESCE(SUM(total_amount), 0)
            FROM orders 
            WHERE customer_id = NEW.customer_id 
                AND order_status = 'Delivered'
        )
        WHERE customer_id = NEW.customer_id;
    END IF;
END //
DELIMITER ;

-- Trigger to automatically update inventory when order items are added
DELIMITER //
CREATE TRIGGER tr_update_inventory_after_order_item
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status VARCHAR(20);
    
    -- Get order status
    SELECT order_status INTO order_status
    FROM orders 
    WHERE order_id = NEW.order_id;
    
    -- Only update inventory for non-cancelled orders
    IF order_status != 'Cancelled' THEN
        CALL sp_update_inventory_on_sale(NEW.book_id, NEW.quantity);
    END IF;
END //
DELIMITER ;

-- Trigger to prevent negative inventory
DELIMITER //
CREATE TRIGGER tr_prevent_negative_inventory
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity_in_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Inventory quantity cannot be negative';
    END IF;
END //
DELIMITER ;

-- ===========================
-- 5. INDEXES FOR PERFORMANCE
-- ===========================

-- Additional indexes for better query performance
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_book ON order_items(book_id);
CREATE INDEX idx_reviews_book_rating ON reviews(book_id, rating);
CREATE INDEX idx_books_price_category ON books(price, category_id);
CREATE INDEX idx_inventory_stock_status ON inventory(quantity_in_stock, reorder_level);

-- Composite indexes for complex queries
CREATE INDEX idx_books_author_category ON books(author_id, category_id);
CREATE INDEX idx_orders_status_date ON orders(order_status, order_date);
CREATE INDEX idx_customers_membership_spent ON customers(membership_level, total_spent);

-- ===========================
-- 6. EXAMPLE USAGE OF CREATED OBJECTS
-- ===========================

-- Using views
SELECT * FROM v_book_details WHERE avg_rating > 4.0;
SELECT * FROM v_customer_summary WHERE total_spent > 50;
SELECT * FROM v_inventory_status WHERE stock_status = 'REORDER_REQUIRED';

-- Using stored procedures
-- CALL sp_add_new_book('Test Book', '978-1234567890', 1, 1, 1, '2024-01-01', 300, 'English', 19.99, 12.00, 'Test description', 50, 10, 100);
-- CALL sp_sales_report('2024-01-01', '2024-12-31');

-- Using functions
SELECT 
    title,
    price,
    fn_book_availability(book_id) as availability_status
FROM books
LIMIT 10;

SELECT 
    customer_id,
    100.00 as order_amount,
    fn_calculate_customer_discount(customer_id, 100.00) as discount
FROM customers
WHERE membership_level != 'Bronze'
LIMIT 5;

-- Performance monitoring query
EXPLAIN SELECT 
    b.title,
    a.first_name,
    a.last_name,
    AVG(r.rating) as avg_rating
FROM books b
JOIN authors a ON b.author_id = a.author_id
LEFT JOIN reviews r ON b.book_id = r.book_id
WHERE b.price BETWEEN 10 AND 20
GROUP BY b.book_id
HAVING avg_rating > 3.5
ORDER BY avg_rating DESC;
