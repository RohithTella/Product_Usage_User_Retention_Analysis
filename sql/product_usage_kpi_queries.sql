USE product_usage_retention;

CREATE TABLE product_usage (
    Invoice VARCHAR(20),
    StockCode VARCHAR(30),
    Description TEXT,
    Quantity INT,
    InvoiceDate VARCHAR(30),
    InvoiceYear INT,
    InvoiceMonth INT,
    Price DECIMAL(10,2),
    TotalAmount DECIMAL(12,2),
    CustomerID INT,
    Country VARCHAR(100)
);

DROP TABLE IF EXISTS product_usage;

CREATE TABLE product_usage (
    Invoice VARCHAR(50),
    StockCode VARCHAR(50),
    Description TEXT,
    Quantity VARCHAR(50),
    InvoiceDate VARCHAR(50),
    InvoiceYear VARCHAR(10),
    InvoiceMonth VARCHAR(10),
    Price VARCHAR(50),
    TotalAmount VARCHAR(50),
    CustomerID VARCHAR(50),
    Country VARCHAR(100)
);

TRUNCATE TABLE product_usage;

SELECT COUNT(*) from product_usage;

SHOW GLOBAL VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/temp/product_usage_cleaned.csv'
INTO TABLE product_usage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT COUNT(*) FROM product_usage;

DROP TABLE IF EXISTS usage_clean;

CREATE TABLE usage_clean AS
SELECT *
FROM product_usage
WHERE CustomerID IS NOT NULL
  AND CustomerID <> ''
  AND Quantity IS NOT NULL
  AND Quantity <> ''
  AND Price IS NOT NULL
  AND Price <> '';
  
SELECT COUNT(*) FROM usage_clean;

-- Total revenue from all valid transactions
SELECT ROUND(SUM(TotalAmount), 2) AS total_revenue
FROM usage_clean;

-- Total unique orders (invoices)
SELECT COUNT(DISTINCT Invoice) AS total_orders
FROM usage_clean;

-- Total unique customers
SELECT COUNT(DISTINCT CustomerID) AS unique_customers
FROM usage_clean;

-- Monthly revenue trend
SELECT 
    InvoiceYear,
    InvoiceMonth,
    ROUND(SUM(TotalAmount), 2) AS monthly_revenue
FROM usage_clean
GROUP BY InvoiceYear, InvoiceMonth
ORDER BY InvoiceYear, InvoiceMonth;

-- Monthly active customers
SELECT 
    InvoiceYear,
    InvoiceMonth,
    COUNT(DISTINCT CustomerID) AS monthly_active_customers
FROM usage_clean
GROUP BY InvoiceYear, InvoiceMonth
ORDER BY InvoiceYear, InvoiceMonth;

-- First purchase month of each customer
SELECT 
    CustomerID,
    MIN(CONCAT(InvoiceYear, '-', LPAD(InvoiceMonth, 2, '0'))) AS first_month
FROM usage_clean
GROUP BY CustomerID;

-- New vs Returning customers by month
WITH first_purchase AS (
    SELECT 
        CustomerID,
        MIN(CONCAT(InvoiceYear, '-', LPAD(InvoiceMonth, 2, '0'))) AS first_month
    FROM usage_clean
    GROUP BY CustomerID
),
monthly_customers AS (
    SELECT DISTINCT
        CustomerID,
        CONCAT(InvoiceYear, '-', LPAD(InvoiceMonth, 2, '0')) AS current_month
    FROM usage_clean
)
SELECT
    current_month,
    COUNT(CASE WHEN current_month = first_month THEN 1 END) AS new_customers,
    COUNT(CASE WHEN current_month <> first_month THEN 1 END) AS returning_customers
FROM monthly_customers mc
JOIN first_purchase fp ON mc.CustomerID = fp.CustomerID
GROUP BY current_month
ORDER BY current_month;

-- Repeat purchase customers and rate
WITH customer_orders AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT Invoice) AS total_orders
    FROM usage_clean
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN total_orders >= 2 THEN 1 END) AS repeat_customers,
    ROUND(
        (COUNT(CASE WHEN total_orders >= 2 THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS repeat_purchase_rate_percent
FROM customer_orders;


-- Retention cohort table: cohort month vs retention month number
WITH customer_months AS (
    SELECT DISTINCT
        CustomerID,
        STR_TO_DATE(CONCAT(InvoiceYear,'-',LPAD(InvoiceMonth,2,'0'),'-01'), '%Y-%m-%d') AS activity_month
    FROM usage_clean
),
cohort AS (
    SELECT
        CustomerID,
        MIN(activity_month) AS cohort_month
    FROM customer_months
    GROUP BY CustomerID
),
cohort_data AS (
    SELECT
        cm.CustomerID,
        c.cohort_month,
        cm.activity_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, cm.activity_month) AS month_number
    FROM customer_months cm
    JOIN cohort c ON cm.CustomerID = c.CustomerID
)
SELECT
    DATE_FORMAT(cohort_month, '%Y-%m') AS cohort_month,
    month_number,
    COUNT(DISTINCT CustomerID) AS retained_customers
FROM cohort_data
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number; 

-- Top 10 products by total revenue
SELECT
    Description,
    ROUND(SUM(TotalAmount), 2) AS product_revenue
FROM usage_clean
GROUP BY Description
ORDER BY product_revenue DESC
LIMIT 10;

-- Top 10 products by total quantity sold
SELECT
    Description,
    SUM(CAST(Quantity AS SIGNED)) AS total_quantity
FROM usage_clean
GROUP BY Description
ORDER BY total_quantity DESC
LIMIT 10;

-- Revenue and customer count by country
SELECT
    Country,
    ROUND(SUM(TotalAmount), 2) AS country_revenue,
    COUNT(DISTINCT CustomerID) AS customer_count
FROM usage_clean
GROUP BY Country
ORDER BY country_revenue DESC;

-- Top 10 countries contribution % of total revenue
SELECT
    Country,
    ROUND(SUM(TotalAmount), 2) AS country_revenue,
    ROUND((SUM(TotalAmount) * 100) / (SELECT SUM(TotalAmount) FROM usage_clean), 2) AS revenue_percent
FROM usage_clean
GROUP BY Country
ORDER BY country_revenue DESC
LIMIT 10;

-- Top 10 products contribution % of total revenue
SELECT
    Description,
    ROUND(SUM(TotalAmount), 2) AS product_revenue,
    ROUND((SUM(TotalAmount) * 100) / (SELECT SUM(TotalAmount) FROM usage_clean), 2) AS revenue_percent
FROM usage_clean
GROUP BY Description
ORDER BY product_revenue DESC
LIMIT 10;
