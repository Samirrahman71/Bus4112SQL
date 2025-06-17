-- =========================================
-- SQL BOOKSTORE PROJECT - SAMPLE DATA
-- =========================================
-- This file populates the database with realistic sample data
-- Demonstrates: INSERT statements, data relationships, realistic scenarios

-- ===========================
-- 1. INSERT AUTHORS
-- ===========================
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography) VALUES
('Stephen', 'King', '1947-09-21', 'American', 'Master of horror and supernatural fiction, known for novels like The Shining and IT.'),
('Agatha', 'Christie', '1890-09-15', 'British', 'Best-selling mystery writer, creator of Hercule Poirot and Miss Marple.'),
('J.K.', 'Rowling', '1965-07-31', 'British', 'Author of the Harry Potter series, one of the best-selling book series in history.'),
('George', 'Orwell', '1903-06-25', 'British', 'Author of dystopian classics 1984 and Animal Farm.'),
('Jane', 'Austen', '1775-12-16', 'British', 'Regency-era novelist known for Pride and Prejudice and Emma.'),
('Ernest', 'Hemingway', '1899-07-21', 'American', 'Nobel Prize winner known for A Farewell to Arms and The Old Man and the Sea.'),
('Toni', 'Morrison', '1931-02-18', 'American', 'Nobel Prize winner, author of Beloved and Song of Solomon.'),
('Harper', 'Lee', '1926-04-28', 'American', 'Author of To Kill a Mockingbird.'),
('F. Scott', 'Fitzgerald', '1896-09-24', 'American', 'Author of The Great Gatsby.'),
('Mark', 'Twain', '1835-11-30', 'American', 'Author of Adventures of Huckleberry Finn and Tom Sawyer.'),
('Virginia', 'Woolf', '1882-01-25', 'British', 'Modernist writer known for Mrs. Dalloway and To the Lighthouse.'),
('Gabriel', 'García Márquez', '1927-03-06', 'Colombian', 'Nobel Prize winner, master of magical realism.'),
('Chimamanda Ngozi', 'Adichie', '1977-09-15', 'Nigerian', 'Contemporary author known for Americanah and Half of a Yellow Sun.'),
('Haruki', 'Murakami', '1949-01-12', 'Japanese', 'Contemporary author known for surreal and magical realist works.'),
('Margaret', 'Atwood', '1939-11-18', 'Canadian', 'Author of The Handmaid\'s Tale and Oryx and Crake.');

-- ===========================
-- 2. INSERT PUBLISHERS
-- ===========================
INSERT INTO publishers (publisher_name, address, city, country, phone, email, website, founded_year) VALUES
('Penguin Random House', '1745 Broadway', 'New York', 'USA', '+1-212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com', 2013),
('HarperCollins', '195 Broadway', 'New York', 'USA', '+1-212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com', 1989),
('Simon & Schuster', '1230 Avenue of the Americas', 'New York', 'USA', '+1-212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com', 1924),
('Macmillan Publishers', '120 Broadway', 'New York', 'USA', '+1-646-307-5151', 'info@macmillan.com', 'www.macmillan.com', 1843),
('Hachette Book Group', '1290 Avenue of the Americas', 'New York', 'USA', '+1-212-364-1100', 'info@hachettebookgroup.com', 'www.hachettebookgroup.com', 2006),
('Scholastic Corporation', '557 Broadway', 'New York', 'USA', '+1-212-343-6100', 'info@scholastic.com', 'www.scholastic.com', 1920),
('Oxford University Press', 'Great Clarendon Street', 'Oxford', 'UK', '+44-1865-556767', 'enquiry@oup.com', 'www.oup.com', 1586),
('Cambridge University Press', 'University Printing House', 'Cambridge', 'UK', '+44-1223-358331', 'information@cambridge.org', 'www.cambridge.org', 1534),
('Vintage Books', '1745 Broadway', 'New York', 'USA', '+1-212-751-2600', 'info@vintage.com', 'www.vintage.com', 1954),
('Bloomsbury Publishing', '50 Bedford Square', 'London', 'UK', '+44-20-7631-5600', 'contact@bloomsbury.com', 'www.bloomsbury.com', 1986);

-- ===========================
-- 3. INSERT CATEGORIES
-- ===========================
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Fiction', 'Fictional works including novels and short stories', NULL),
('Non-Fiction', 'Factual books including biographies, history, science', NULL),
('Children''s Books', 'Books specifically written for children', NULL),
('Academic', 'Textbooks and scholarly works', NULL),
('Mystery', 'Detective and mystery novels', 1),
('Horror', 'Horror and supernatural fiction', 1),
('Romance', 'Romantic fiction', 1),
('Science Fiction', 'Science fiction and fantasy', 1),
('Classic Literature', 'Timeless literary works', 1),
('Biography', 'Life stories of notable people', 2),
('History', 'Historical accounts and analysis', 2),
('Science', 'Scientific books and research', 2),
('Self-Help', 'Personal development and improvement', 2),
('Picture Books', 'Illustrated books for young children', 3),
('Young Adult', 'Books targeted at teenage readers', 3);

-- ===========================
-- 4. INSERT BOOKS
-- ===========================
INSERT INTO books (title, isbn, author_id, publisher_id, category_id, publication_date, page_count, price, cost, description) VALUES
('The Shining', '978-0-307-74365-9', 1, 1, 6, '1977-01-28', 447, 15.99, 8.50, 'A family heads to an isolated hotel for the winter where a sinister presence influences the father into violence.'),
('Murder on the Orient Express', '978-0-06-207350-4', 2, 2, 5, '1934-01-01', 256, 14.99, 7.25, 'Hercule Poirot investigates a murder aboard the famous Orient Express.'),
('Harry Potter and the Philosopher''s Stone', '978-0-7475-3269-9', 3, 10, 8, '1997-06-26', 223, 12.99, 6.50, 'A young wizard discovers his magical heritage on his 11th birthday.'),
('1984', '978-0-452-28423-4', 4, 1, 9, '1949-06-08', 328, 13.99, 7.00, 'A dystopian social science fiction novel about totalitarian control.'),
('Pride and Prejudice', '978-0-14-143951-8', 5, 1, 9, '1813-01-28', 432, 11.99, 6.00, 'A romantic novel about manners, upbringing, morality, and marriage.'),
('The Old Man and the Sea', '978-0-684-80122-3', 6, 3, 9, '1952-09-01', 127, 10.99, 5.50, 'An aging Cuban fisherman struggles with a giant marlin.'),
('Beloved', '978-1-4000-3341-6', 7, 9, 9, '1987-09-02', 321, 16.99, 8.75, 'A former slave is haunted by the trauma of her past and the ghost of her dead daughter.'),
('To Kill a Mockingbird', '978-0-06-112008-4', 8, 2, 9, '1960-07-11', 376, 14.99, 7.50, 'A lawyer defends a black man against false charges in the American South.'),
('The Great Gatsby', '978-0-7432-7356-5', 9, 3, 9, '1925-04-10', 180, 12.99, 6.50, 'A critique of the American Dream set in the Jazz Age.'),
('Adventures of Huckleberry Finn', '978-0-486-28061-4', 10, 1, 9, '1884-12-10', 366, 9.99, 5.00, 'A boy and a runaway slave travel down the Mississippi River.'),
('Mrs. Dalloway', '978-0-15-662870-9', 11, 2, 9, '1925-05-14', 194, 13.99, 7.00, 'A day in the life of Clarissa Dalloway in post-World War I England.'),
('One Hundred Years of Solitude', '978-0-06-088328-7', 12, 2, 8, '1967-05-30', 417, 17.99, 9.00, 'Multi-generational story of the Buendía family in the fictional town of Macondo.'),
('Americanah', '978-0-307-45591-6', 13, 1, 1, '2013-05-14', 477, 16.99, 8.50, 'A young Nigerian woman navigates race and identity in America and Nigeria.'),
('Norwegian Wood', '978-0-375-70423-8', 14, 9, 1, '1987-08-04', 296, 15.99, 8.00, 'A coming-of-age story set in 1960s Tokyo.'),
('The Handmaid''s Tale', '978-0-385-49081-8', 15, 1, 8, '1985-08-01', 311, 15.99, 8.00, 'A dystopian novel about women''s rights and religious fundamentalism.'),
('IT', '978-1-5011-4215-0', 1, 3, 6, '1986-09-15', 1138, 18.99, 9.50, 'Children in a small town are terrorized by an evil entity.'),
('And Then There Were None', '978-0-06-207349-8', 2, 2, 5, '1939-11-06', 272, 13.99, 7.00, 'Ten strangers are invited to an island where they are murdered one by one.'),
('Harry Potter and the Chamber of Secrets', '978-0-439-06486-6', 3, 6, 8, '1998-07-02', 251, 12.99, 6.50, 'Harry returns to Hogwarts to face the mystery of the Chamber of Secrets.'),
('Animal Farm', '978-0-452-28424-1', 4, 1, 9, '1945-08-17', 112, 10.99, 5.50, 'A satirical allegorical novella about farm animals who rebel against their farmer.'),
('Emma', '978-0-14-143960-0', 5, 1, 9, '1815-12-23', 474, 12.99, 6.50, 'A young woman meddles in the romantic lives of her friends.');

-- ===========================
-- 5. INSERT CUSTOMERS
-- ===========================
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, membership_level, address_line1, city, state_province, postal_code, country) VALUES
('John', 'Smith', 'john.smith@email.com', '+1-555-0101', '1985-03-15', 'Male', 'Gold', '123 Main St', 'New York', 'NY', '10001', 'USA'),
('Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0102', '1990-07-22', 'Female', 'Silver', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA'),
('Michael', 'Brown', 'michael.brown@email.com', '+1-555-0103', '1988-11-08', 'Male', 'Bronze', '789 Pine St', 'Chicago', 'IL', '60601', 'USA'),
('Emily', 'Davis', 'emily.davis@email.com', '+1-555-0104', '1992-05-30', 'Female', 'Platinum', '321 Elm St', 'Houston', 'TX', '77001', 'USA'),
('David', 'Wilson', 'david.wilson@email.com', '+1-555-0105', '1987-09-12', 'Male', 'Silver', '654 Maple Ave', 'Phoenix', 'AZ', '85001', 'USA'),
('Lisa', 'Garcia', 'lisa.garcia@email.com', '+1-555-0106', '1991-01-18', 'Female', 'Gold', '987 Cedar St', 'Philadelphia', 'PA', '19101', 'USA'),
('Robert', 'Martinez', 'robert.martinez@email.com', '+1-555-0107', '1989-04-25', 'Male', 'Bronze', '147 Birch Ave', 'San Antonio', 'TX', '78201', 'USA'),
('Jennifer', 'Lopez', 'jennifer.lopez@email.com', '+1-555-0108', '1993-08-14', 'Female', 'Silver', '258 Spruce St', 'San Diego', 'CA', '92101', 'USA'),
('William', 'Anderson', 'william.anderson@email.com', '+1-555-0109', '1986-12-03', 'Male', 'Gold', '369 Walnut Ave', 'Dallas', 'TX', '75201', 'USA'),
('Ashley', 'Taylor', 'ashley.taylor@email.com', '+1-555-0110', '1994-06-09', 'Female', 'Bronze', '741 Chestnut St', 'San Jose', 'CA', '95101', 'USA'),
('Christopher', 'Thomas', 'christopher.thomas@email.com', '+1-555-0111', '1990-10-21', 'Male', 'Silver', '852 Hickory Ave', 'Austin', 'TX', '73301', 'USA'),
('Amanda', 'Jackson', 'amanda.jackson@email.com', '+1-555-0112', '1987-02-28', 'Female', 'Platinum', '963 Poplar St', 'Jacksonville', 'FL', '32099', 'USA'),
('Matthew', 'White', 'matthew.white@email.com', '+1-555-0113', '1991-07-16', 'Male', 'Gold', '159 Sycamore Ave', 'Fort Worth', 'TX', '76101', 'USA'),
('Jessica', 'Harris', 'jessica.harris@email.com', '+1-555-0114', '1989-11-05', 'Female', 'Silver', '753 Willow St', 'Columbus', 'OH', '43085', 'USA'),
('Daniel', 'Martin', 'daniel.martin@email.com', '+1-555-0115', '1988-03-27', 'Male', 'Bronze', '864 Dogwood Ave', 'Charlotte', 'NC', '28202', 'USA');

-- ===========================
-- 6. INSERT ORDERS
-- ===========================
INSERT INTO orders (customer_id, order_date, order_status, subtotal, tax_amount, shipping_cost, total_amount, payment_method, shipping_address_line1, shipping_city, shipping_state, shipping_postal_code, shipping_country) VALUES
(1, '2024-01-15 10:30:00', 'Delivered', 28.98, 2.32, 5.99, 37.29, 'Credit Card', '123 Main St', 'New York', 'NY', '10001', 'USA'),
(2, '2024-01-20 14:45:00', 'Delivered', 15.99, 1.28, 3.99, 21.26, 'PayPal', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA'),
(3, '2024-02-01 09:15:00', 'Shipped', 41.97, 3.36, 7.99, 53.32, 'Credit Card', '789 Pine St', 'Chicago', 'IL', '60601', 'USA'),
(4, '2024-02-05 16:20:00', 'Processing', 67.95, 5.44, 0.00, 73.39, 'Credit Card', '321 Elm St', 'Houston', 'TX', '77001', 'USA'),
(5, '2024-02-10 11:00:00', 'Delivered', 24.98, 2.00, 4.99, 31.97, 'Debit Card', '654 Maple Ave', 'Phoenix', 'AZ', '85001', 'USA'),
(6, '2024-02-14 13:30:00', 'Delivered', 32.97, 2.64, 5.99, 41.60, 'Credit Card', '987 Cedar St', 'Philadelphia', 'PA', '19101', 'USA'),
(7, '2024-02-18 15:45:00', 'Cancelled', 18.99, 1.52, 3.99, 24.50, 'PayPal', '147 Birch Ave', 'San Antonio', 'TX', '78201', 'USA'),
(8, '2024-02-22 10:10:00', 'Shipped', 29.98, 2.40, 5.99, 38.37, 'Credit Card', '258 Spruce St', 'San Diego', 'CA', '92101', 'USA'),
(9, '2024-02-25 12:25:00', 'Delivered', 43.96, 3.52, 7.99, 55.47, 'Credit Card', '369 Walnut Ave', 'Dallas', 'TX', '75201', 'USA'),
(10, '2024-03-01 14:40:00', 'Processing', 25.98, 2.08, 4.99, 33.05, 'Debit Card', '741 Chestnut St', 'San Jose', 'CA', '95101', 'USA'),
(11, '2024-03-05 09:55:00', 'Delivered', 34.97, 2.80, 5.99, 43.76, 'PayPal', '852 Hickory Ave', 'Austin', 'TX', '73301', 'USA'),
(12, '2024-03-08 16:15:00', 'Shipped', 51.96, 4.16, 7.99, 64.11, 'Credit Card', '963 Poplar St', 'Jacksonville', 'FL', '32099', 'USA'),
(13, '2024-03-12 11:20:00', 'Delivered', 19.98, 1.60, 3.99, 25.57, 'Credit Card', '159 Sycamore Ave', 'Fort Worth', 'TX', '76101', 'USA'),
(14, '2024-03-15 13:35:00', 'Processing', 37.97, 3.04, 5.99, 47.00, 'Debit Card', '753 Willow St', 'Columbus', 'OH', '43085', 'USA'),
(15, '2024-03-18 15:50:00', 'Pending', 22.98, 1.84, 4.99, 29.81, 'PayPal', '864 Dogwood Ave', 'Charlotte', 'NC', '28202', 'USA');

-- ===========================
-- 7. INSERT ORDER_ITEMS
-- ===========================
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) VALUES
-- Order 1: Customer 1
(1, 1, 1, 15.99, 15.99),
(1, 4, 1, 13.99, 13.99),
-- Order 2: Customer 2
(2, 3, 1, 12.99, 12.99),
-- Order 3: Customer 3
(3, 5, 2, 11.99, 23.98),
(3, 6, 1, 10.99, 10.99),
(3, 19, 1, 10.99, 10.99),
-- Order 4: Customer 4
(4, 7, 1, 16.99, 16.99),
(4, 12, 1, 17.99, 17.99),
(4, 13, 1, 16.99, 16.99),
(4, 14, 1, 15.99, 15.99),
-- Order 5: Customer 5
(5, 8, 1, 14.99, 14.99),
(5, 9, 1, 12.99, 12.99),
-- Order 6: Customer 6  
(6, 10, 1, 9.99, 9.99),
(6, 11, 1, 13.99, 13.99),
(6, 20, 1, 12.99, 12.99),
-- Order 7: Customer 7 (Cancelled)
(7, 16, 1, 18.99, 18.99),
-- Order 8: Customer 8
(8, 2, 1, 14.99, 14.99),
(8, 17, 1, 13.99, 13.99),
-- Order 9: Customer 9
(9, 15, 1, 15.99, 15.99),
(9, 1, 1, 15.99, 15.99),
(9, 4, 1, 13.99, 13.99),
-- Order 10: Customer 10
(10, 3, 2, 12.99, 25.98),
-- Order 11: Customer 11
(11, 18, 1, 12.99, 12.99),
(11, 5, 1, 11.99, 11.99),
(11, 6, 1, 10.99, 10.99),
-- Order 12: Customer 12
(12, 7, 1, 16.99, 16.99),
(12, 13, 1, 16.99, 16.99),
(12, 14, 1, 15.99, 15.99),
-- Order 13: Customer 13
(13, 9, 1, 12.99, 12.99),
(13, 19, 1, 10.99, 10.99),
-- Order 14: Customer 14
(14, 12, 1, 17.99, 17.99),
(14, 2, 1, 14.99, 14.99),
(14, 8, 1, 14.99, 14.99),
-- Order 15: Customer 15
(15, 11, 1, 13.99, 13.99),
(15, 20, 1, 12.99, 12.99);

-- ===========================
-- 8. INSERT INVENTORY
-- ===========================
INSERT INTO inventory (book_id, quantity_in_stock, reorder_level, max_stock_level, last_restocked_date, location) VALUES
(1, 45, 10, 100, '2024-01-10', 'A-1-A'),
(2, 32, 10, 80, '2024-01-15', 'A-1-B'),
(3, 67, 15, 150, '2024-02-01', 'A-2-A'),
(4, 28, 10, 75, '2024-01-20', 'A-2-B'),
(5, 41, 10, 90, '2024-01-25', 'A-3-A'),
(6, 23, 8, 60, '2024-02-05', 'A-3-B'),
(7, 19, 10, 70, '2024-02-10', 'B-1-A'),
(8, 35, 10, 85, '2024-01-30', 'B-1-B'),
(9, 52, 12, 95, '2024-02-15', 'B-2-A'),
(10, 38, 10, 80, '2024-02-20', 'B-2-B'),
(11, 26, 8, 65, '2024-01-28', 'B-3-A'),
(12, 14, 10, 60, '2024-02-25', 'B-3-B'),
(13, 31, 10, 75, '2024-02-18', 'C-1-A'),
(14, 22, 8, 70, '2024-02-22', 'C-1-B'),
(15, 29, 10, 80, '2024-02-28', 'C-2-A'),
(16, 18, 10, 65, '2024-03-01', 'C-2-B'),
(17, 33, 10, 85, '2024-02-12', 'C-3-A'),
(18, 44, 12, 90, '2024-03-05', 'C-3-B'),
(19, 27, 8, 70, '2024-03-08', 'D-1-A'),
(20, 36, 10, 80, '2024-03-10', 'D-1-B');

-- ===========================
-- 9. INSERT REVIEWS
-- ===========================
INSERT INTO reviews (book_id, customer_id, rating, review_title, review_text, is_verified_purchase, helpful_votes) VALUES
(1, 1, 5, 'Absolutely Terrifying!', 'Stephen King at his finest. Could not put this book down, even though it kept me up at night!', TRUE, 15),
(3, 2, 5, 'Magical Beginning', 'The perfect start to an incredible series. Rowling creates a world you never want to leave.', TRUE, 23),
(4, 1, 4, 'Chilling and Relevant', 'More relevant today than ever. Orwell\'s vision is both frightening and compelling.', TRUE, 18),
(5, 3, 5, 'Timeless Romance', 'Austen\'s wit and social commentary wrapped in a beautiful love story.', FALSE, 12),
(7, 4, 5, 'Powerful and Moving', 'Morrison\'s prose is haunting and beautiful. A difficult but important read.', TRUE, 27),
(8, 5, 5, 'American Classic', 'A book everyone should read. Harper Lee\'s message is as important today as it was then.', TRUE, 31),
(9, 9, 4, 'Great Gatsby Lives Up to Hype', 'Beautiful writing and symbolism. The American Dream dissected perfectly.', TRUE, 14),
(12, 4, 5, 'Magical Realism at its Best', 'García Márquez weaves an incredible multi-generational tale.', TRUE, 20),
(13, 6, 4, 'Contemporary Masterpiece', 'Adichie tackles race and identity with nuance and grace.', FALSE, 16),
(15, 9, 5, 'Dystopian Brilliance', 'Atwood\'s vision is terrifying because it feels so possible.', TRUE, 22),
(2, 8, 4, 'Classic Mystery', 'Agatha Christie never disappoints. Great puzzle to solve along with Poirot.', TRUE, 9),
(6, 5, 3, 'Simple but Profound', 'Short read but packs an emotional punch. Hemingway\'s style is unmistakable.', TRUE, 7),
(10, 11, 4, 'American Adventure', 'Twain\'s humor and social commentary make this a joy to read.', FALSE, 11),
(14, 13, 5, 'Haunting and Beautiful', 'Murakami\'s ability to blend reality and surrealism is unmatched.', TRUE, 19),
(16, 7, 5, 'King of Horror', 'IT is terrifying in the best possible way. Stephen King creates genuine fear.', FALSE, 25);

-- ===========================
-- 10. INSERT BOOK_AUTHORS (Many-to-Many)
-- ===========================
-- Most books have single authors, but let's add a few collaborative works
INSERT INTO book_authors (book_id, author_id, author_role) VALUES
-- Single author books (primary authors)
(1, 1, 'Primary Author'),
(2, 2, 'Primary Author'),
(3, 3, 'Primary Author'),
(4, 4, 'Primary Author'),
(5, 5, 'Primary Author'),
(6, 6, 'Primary Author'),
(7, 7, 'Primary Author'),
(8, 8, 'Primary Author'),
(9, 9, 'Primary Author'),
(10, 10, 'Primary Author'),
(11, 11, 'Primary Author'),
(12, 12, 'Primary Author'),
(13, 13, 'Primary Author'),
(14, 14, 'Primary Author'),
(15, 15, 'Primary Author'),
(16, 1, 'Primary Author'),
(17, 2, 'Primary Author'),
(18, 3, 'Primary Author'),
(19, 4, 'Primary Author'),
(20, 5, 'Primary Author');

-- Update customer total_spent based on orders
UPDATE customers 
SET total_spent = (
    SELECT COALESCE(SUM(total_amount), 0)
    FROM orders 
    WHERE orders.customer_id = customers.customer_id 
    AND order_status IN ('Delivered', 'Shipped', 'Processing')
);

-- Show sample of inserted data
SELECT 'Data insertion completed successfully!' as status;
SELECT COUNT(*) as total_authors FROM authors;
SELECT COUNT(*) as total_books FROM books;
SELECT COUNT(*) as total_customers FROM customers;
SELECT COUNT(*) as total_orders FROM orders;
SELECT COUNT(*) as total_reviews FROM reviews;
