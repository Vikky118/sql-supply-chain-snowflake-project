
-- =====================================================
-- SUPPLY CHAIN SQL PROJECT
-- Snowflake Schema + Case Study Queries
-- Author: Vikas Ranjan
-- =====================================================

-- ===============================
-- 1. DIMENSION TABLES (SNOWFLAKE)
-- ===============================

CREATE TABLE dim_country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100)
);

CREATE TABLE dim_city (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

CREATE TABLE dim_supplier (
    supplier_id INT PRIMARY KEY,
    company_name VARCHAR(150),
    contact_name VARCHAR(150),
    phone VARCHAR(20),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    unit_price DECIMAL(10,2),
    is_discontinued BOOLEAN,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT
);

-- ===============================
-- 2. FACT TABLE
-- ===============================

CREATE TABLE fact_orders (
    order_id INT,
    customer_id INT,
    product_id INT,
    date_id INT,
    quantity INT,
    selling_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- ===============================
-- SECTION A – LEVEL 1 QUERIES
-- ===============================

-- Country-wise customer count
SELECT c.country_name, COUNT(*) AS customer_count
FROM dim_customer dc
JOIN dim_city ci ON dc.city_id = ci.city_id
JOIN dim_country c ON ci.country_id = c.country_id
GROUP BY c.country_name;

-- Active products
SELECT * FROM dim_product WHERE is_discontinued = 0;

-- Supplier and products
SELECT s.company_name, p.product_name
FROM dim_supplier s
JOIN dim_product p ON s.supplier_id = p.supplier_id;

-- Customers from Mexico
SELECT dc.*
FROM dim_customer dc
JOIN dim_city ci ON dc.city_id = ci.city_id
JOIN dim_country c ON ci.country_id = c.country_id
WHERE c.country_name = 'Mexico';

-- ===============================
-- SECTION B – LEVEL 2 QUERIES
-- ===============================

-- High demand products
SELECT p.product_name, SUM(f.quantity) AS demand
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY demand DESC;

-- Year-wise revenue
SELECT d.year, SUM(f.total_amount) AS revenue
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year;

-- Customer spending
SELECT dc.first_name, dc.last_name, SUM(f.total_amount) AS total_spent
FROM fact_orders f
JOIN dim_customer dc ON f.customer_id = dc.customer_id
GROUP BY dc.customer_id
ORDER BY total_spent DESC;

-- ===============================
-- SECTION C – LEVEL 3 QUERIES
-- ===============================

-- Customers ordering more than 10 items
SELECT DISTINCT dc.*
FROM fact_orders f
JOIN dim_customer dc ON f.customer_id = dc.customer_id
WHERE f.quantity > 10;

-- High value suppliers
SELECT DISTINCT s.company_name
FROM dim_supplier s
JOIN dim_product p ON s.supplier_id = p.supplier_id
WHERE p.unit_price > 100;

-- ===============================
-- SECTION D – LEVEL 4 QUERIES
-- ===============================

-- Discount savings per order
SELECT f.order_id,
       SUM((p.unit_price - f.selling_price) * f.quantity) AS amount_saved
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY f.order_id
ORDER BY amount_saved DESC;

-- Top demanded products for new supplier
SELECT p.product_name, SUM(f.quantity) AS demand
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY demand DESC
LIMIT 5;

-- =====================================================
-- END OF FILE
-- =====================================================
