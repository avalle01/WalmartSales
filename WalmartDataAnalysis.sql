CREATE DATABASE IF NOT EXISTS walmartDataSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_ID VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL, 
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL, 
    cogs DECIMAL(10, 2) NOT NULL, 
    gross_margin_pct FLOAT(11, 9), 
    gross_income DECIMAL(12, 4) NOT NULL, 
    rating FLOAT(2, 1)
);

-- ---------------------------------------------------------------------------------------
-- ----------------------------Feature Engineering----------------------------------------

-- ADDING time_of_day
SELECT
	time,
    (CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
END
);

-- ADDING day_name
SELECT
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date);

-- ADDING month_name 
SELECT 
	date,
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------------------------------
-- ----------------------------Exploratory Data Analysis---------------------------------------
-- Business Questions:
-- 1. How many unique cities does the data have?
SELECT
	DISTINCT city
FROM sales;

-- 2. In which city is each branch?
SELECT
	DISTINCT branch
FROM sales;

SELECT
	DISTINCT city,
    branch
FROM sales;

-- Product
-- 1. How many unque product lines does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;

-- 2. What is the most common payment method?
SELECT
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- 3. What is the most selling product line?
SELECT
    product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- 4. What is the total revenue by month?
SELECT
    month_name AS month,
    SUM(total) AS total_rev
FROM sales
GROUP BY month_name
ORDER BY total_rev DESC;

-- 5. What month has the largest COGS?
SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- 6. What product line has the largest revenue?
SELECT 
	product_line AS prod,
    SUM(total) AS total
FROM sales
GROUP BY product_line
ORDER BY total DESC;

-- 7. What is the city with the largest revenue?
SELECT 
	city AS city,
    SUM(total) AS total
FROM sales
GROUP BY city
ORDER BY total DESC;

-- 8. What product line had the largest VAT?
SELECT 
	product_line AS product,
    AVG(VAT) AS AVG_VAT
FROM sales
GROUP BY product_line
ORDER BY AVG_VAT DESC;

-- 9. Fetch each product line and add column to those product showing "good", "bad". Good if its greater than average sales
SELECT
	AVG(quantity) AS avg_quantity
FROM sales;

SELECT
	product_line,
    CASE
		WHEN AVG(quantity) > 6 THEN 'Good'
	ELSE 'Bad'
    END AS remark
FROM sales
GROUP BY product_line;
	
-- 10. Which branch sold more products than average products sold?
SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender?
SELECT 
	gender,
    product_line, 
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- 12. What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) AS avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Sales
-- 1. Number of sales made in each time of the day per weekday?
SELECT
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types bring the most revenue?
SELECT
	customer_type,
    SUM(total) as total
FROM sales
GROUP BY customer_type
ORDER BY total DESC;

-- 3. Which city has the largest tax percent/TAX?
SELECT
	city,
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- 4. Which customer type pays the most in VAT?
SELECT
	customer_type,
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- Customer 
-- 1. How many unique characters does the data have
SELECT
	DISTINCT customer_type
FROM sales;

-- 2. How many unique payment methods does the data have?
SELECT 
	DISTINCT payment_method
FROM sales;

-- 3. Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(*) AS customer_count
FROM sales
GROUP BY customer_type;

-- 4. What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- 5. What is the gender distribution per branch?
SELECT
	gender,
    COUNT(*) AS gender_count
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_count DESC;

-- 6. Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 7. Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "B"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8. Which day of the week has the best avg ratings?
SELECT 
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 9. Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- ---------------------------------------------------------
-- -----------------------------------------------
