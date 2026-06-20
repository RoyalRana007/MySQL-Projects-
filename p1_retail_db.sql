CREATE DATABASE p1_retail_db;
USE p1_retail_db;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

#ON Local_Infile
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

#Load data csv file
LOAD DATA LOCAL INFILE 'C:/Users/Royal/Downloads/SQL - Retail Sales Analysis_utf.csv'
INTO TABLE retail_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(transactions_id,
 @sale_date,
 sale_time,
 customer_id,
 gender,
 age,
 category,
 quantity,
 price_per_unit,
 cogs,
 total_sale)
 SET sale_date = STR_TO_DATE(@sale_date,'%m/%d/%Y');
 
 #Verify Data Imported
SELECT * FROM retail_sales LIMIT 10;

#Data Exploration (Total Record)
SELECT COUNT(*) AS total_records
FROM retail_sales;

#Total Unique Customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

#Unique Categories
SELECT DISTINCT category
FROM retail_sales;

#Data Cleaning (Find and delete Null Values)
SELECT * FROM retail_sales
WHERE sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
   
   DELETE FROM retail_sales
WHERE sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
   
   #Question_1: Sales made on 2022-11-05
   SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

#Question_2: Clothing sales with quantity greater than 4 in Nov-2022
SELECT * from retail_sales
WHERE category = 'Clothing'
  AND quantity > 4
  AND YEAR(sale_date) = 2022
  AND MONTH(sale_date) = 11;
  
  #Question_3: Total Sales by Category
  SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

#Question_4: Average Age of Beauty Customers
SELECT
    ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

#Question_5: Transactions Above ₹1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

#Question_6:Transactions by Gender and Category
SELECT category, gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

#Question_7:Best Selling Month in Each Year
WITH monthly_sales AS (
    SELECT
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(
            PARTITION BY YEAR(sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
)

SELECT *
FROM monthly_sales
WHERE rnk = 1;

#Question_8:Top 5 Customers by Sales
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

#Question_9: Unique Customers per Category
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

#Question_10: Orders by Shift
WITH hourly_sales AS
(
    SELECT *,
        CASE
            WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift_time
    FROM retail_sales
)

SELECT
    shift_time,
    COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift_time;

#Extra EDA Queries
#Highest Sale
SELECT MAX(total_sale) AS highest_sale
FROM retail_sales;

#Lowest Sale
SELECT MIN(total_sale) AS lowest_sale
FROM retail_sales;

#Average Sale
SELECT AVG(total_sale) AS average_sale
FROM retail_sales;

#Most Popular Category
SELECT
    category,
    COUNT(*) AS orders_count
FROM retail_sales
GROUP BY category
ORDER BY orders_count DESC;

#Gender-wise Sales
SELECT gender,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender;