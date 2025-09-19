-- Sarita Management Management - Stock Image Purchase Platform Database Schema
-- Created for virtual gallery image sharing and purchase platform

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS purchase_items;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS image_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS users;

-- Users table for customers and administrators
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    address2 VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    user_type ENUM('customer', 'admin') DEFAULT 'customer',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Vendors table for photographers/artists who sell images
CREATE TABLE vendors (
    vendor_id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    portfolio_description TEXT,
    website_url VARCHAR(255),
    social_media_links JSON,
    bank_account_details VARCHAR(255),
    commission_rate DECIMAL(5,2) DEFAULT 15.00,
    status ENUM('pending', 'approved', 'rejected', 'suspended') DEFAULT 'pending',
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approval_date TIMESTAMP NULL,
    total_sales DECIMAL(10,2) DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE
);

-- Categories for organizing images
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Images table for stock photos and artwork
CREATE TABLE images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    file_path VARCHAR(255) NOT NULL,
    thumbnail_path VARCHAR(255),
    file_size_kb INT,
    image_width INT,
    image_height INT,
    file_format VARCHAR(10),
    original_price DECIMAL(8,2) NOT NULL,
    current_price DECIMAL(8,2) NOT NULL,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    license_type ENUM('standard', 'extended', 'exclusive') DEFAULT 'standard',
    tags VARCHAR(500),
    download_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.00,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approval_date TIMESTAMP NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    INDEX idx_vendor_id (vendor_id),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_price (current_price)
);

-- Junction table for image categories (many-to-many relationship)
CREATE TABLE image_categories (
    image_id INT,
    category_id INT,
    PRIMARY KEY (image_id, category_id),
    FOREIGN KEY (image_id) REFERENCES images(image_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Shopping cart items for users
CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_id INT NOT NULL,
    license_type ENUM('standard', 'extended', 'exclusive') DEFAULT 'standard',
    price DECIMAL(8,2) NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES images(image_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, image_id, license_type)
);

-- Purchases table for completed transactions
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100),
    billing_address JSON,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP NULL,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_purchase_date (purchase_date),
    INDEX idx_payment_status (payment_status)
);

-- Individual items in each purchase
CREATE TABLE purchase_items (
    purchase_item_id INT PRIMARY KEY AUTO_INCREMENT,
    purchase_id INT NOT NULL,
    image_id INT NOT NULL,
    vendor_id INT NOT NULL,
    license_type ENUM('standard', 'extended', 'exclusive') NOT NULL,
    item_price DECIMAL(8,2) NOT NULL,
    vendor_commission DECIMAL(8,2) NOT NULL,
    download_url VARCHAR(255),
    download_expires TIMESTAMP NULL,
    download_count INT DEFAULT 0,
    max_downloads INT DEFAULT 10,
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES images(image_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    INDEX idx_purchase_id (purchase_id),
    INDEX idx_image_id (image_id)
);

-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Nature', 'Natural landscapes, wildlife, plants, and outdoor scenes'),
('Travel', 'Tourist destinations, landmarks, and travel-related imagery'),
('Technology', 'Modern technology, gadgets, computers, and digital concepts'),
('Art', 'Artistic creations, paintings, sculptures, and creative works'),
('Architecture', 'Buildings, structures, and architectural elements'),
('Business', 'Corporate environments, meetings, and business concepts'),
('People', 'Portraits, lifestyle, and human activities'),
('Food', 'Culinary photography, ingredients, and dining'),
('Animals', 'Pets, wildlife, and animal photography'),
('Abstract', 'Abstract concepts, patterns, and artistic interpretations');

-- Insert sample admin user
INSERT INTO users (first_name, last_name, email, password_hash, user_type, city, state) VALUES
('Admin', 'User', 'admin@Sarita Management.com', '$2y$10$example_hash_here', 'admin', 'Sydney', 'NSW');

-- Insert sample vendors based on your existing data
INSERT INTO vendors (vendor_name, email, status, approval_date) VALUES
('Shyam Sharma', 'Shyam1@example.com', 'approved', NOW()),
('Hari Kandel', 'Hari9@example.com', 'pending', NULL),
('Radha Acharya', 'Radha7@example.com', 'pending', NULL),
('Sita Gurung', 'sita@example.com', 'approved', NOW()),
('Robert Johnson', 'robert@example.com', 'approved', NOW());

-- Insert sample images based on your existing content
INSERT INTO images (vendor_id, title, description, file_path, original_price, current_price, discount_percentage, status, approval_date) VALUES
(1, 'Opera House', 'Beautiful view of the Sydney Opera House', 'img/9 (10).jpg', 4.00, 2.99, 25.25, 'approved', NOW()),
(1, 'City of Gold Coast', 'Stunning cityscape of Gold Coast', 'img/9 (1).jpg', 3.00, 1.99, 33.67, 'approved', NOW()),
(2, 'Aerial view of Ocean', 'Breathtaking aerial ocean photography', 'img/9 (11).jpg', 6.00, 2.99, 50.17, 'approved', NOW()),
(3, 'Harbour Bridge', 'Iconic Sydney Harbour Bridge photograph', 'img/9 (2).jpg', 4.00, 1.99, 50.25, 'approved', NOW()),
(4, 'Melbourne Cityscape', 'Modern Melbourne city skyline', 'img/9 (6).jpg', 8.00, 5.99, 25.13, 'approved', NOW()),
(5, 'Bird Photography', 'Professional wildlife bird photograph', 'img/9 (9).jpg', 5.00, 3.99, 20.20, 'approved', NOW()),
(5, 'Technology Art', 'Modern technology themed artwork', 'img/technology.jpg', 12.00, 9.99, 16.75, 'approved', NOW()),
(3, 'Eye Wall Art', 'Contemporary eye-themed wall art', 'img/art.jpg', 15.00, 12.99, 13.40, 'approved', NOW()),
(2, 'Ganesh Art', 'Traditional Ganesh artwork', 'img/ganesh (1).jpg', 8.00, 6.99, 12.63, 'approved', NOW()),
(1, 'Nature Scene', 'Beautiful natural landscape', 'img/nature.jpg', 6.00, 4.99, 16.83, 'approved', NOW());

-- Link images to categories
INSERT INTO image_categories (image_id, category_id) VALUES
(1, 5), -- Opera House -> Architecture
(2, 2), -- Gold Coast -> Travel
(3, 1), -- Ocean -> Nature
(4, 5), -- Harbour Bridge -> Architecture
(5, 5), -- Melbourne -> Architecture
(6, 9), -- Bird -> Animals
(7, 3), -- Technology -> Technology
(8, 4), -- Eye Art -> Art
(9, 4), -- Ganesh -> Art
(10, 1); -- Nature -> Nature

-- Create indexes for better performance
CREATE INDEX idx_images_vendor_status ON images(vendor_id, status);
CREATE INDEX idx_images_category ON image_categories(category_id);
CREATE INDEX idx_vendor_status ON vendors(status);
CREATE INDEX idx_user_email ON users(email);

-- Add some views for common queries
CREATE VIEW active_images AS
SELECT 
    i.image_id,
    i.title,
    i.description,
    i.file_path,
    i.current_price,
    i.original_price,
    i.discount_percentage,
    i.download_count,
    v.vendor_name,
    v.vendor_id,
    GROUP_CONCAT(c.category_name) as categories
FROM images i
JOIN vendors v ON i.vendor_id = v.vendor_id
LEFT JOIN image_categories ic ON i.image_id = ic.image_id
LEFT JOIN categories c ON ic.category_id = c.category_id
WHERE i.status = 'approved' AND i.is_active = TRUE AND v.status = 'approved'
GROUP BY i.image_id;

CREATE VIEW vendor_stats AS
SELECT 
    v.vendor_id,
    v.vendor_name,
    v.email,
    v.status,
    COUNT(i.image_id) as total_images,
    SUM(i.download_count) as total_downloads,
    AVG(i.rating) as avg_rating,
    SUM(CASE WHEN i.status = 'approved' THEN 1 ELSE 0 END) as approved_images
FROM vendors v
LEFT JOIN images i ON v.vendor_id = i.vendor_id
GROUP BY v.vendor_id;