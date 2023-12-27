-- Create database
CREATE DATABASE IF NOT EXISTS WallmartSalesDataAnalysis;

-- Create table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_percentage FLOAT(11 , 9 ),
    gross_income DECIMAL(12 , 2 ) NOT NULL,
    rating FLOAT(2 , 1 )
);

-- ------------------------------------------------------------------------------------------------------
-- ----------------------------------------- FEATURE ENGINEERING ----------------------------------------
-- time_of_day

SELECT 
	time,
    (
		CASE
			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
			WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
			ELSE "Evening"
		END
    ) AS time_of_day
FROM
	sales;

-- time_of_day
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END
);

-- ------------------------------------------------------------------------------------------------------
-- day_name
SELECT
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);
-- ------------------------------------------------------------------------------------------------------

-- month_name
SELECT
	date,
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------- GENERIC BUSINESS QUESTIONS -------------------------------------

-- What are the unique cities in the data?
SELECT
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT
	DISTINCT city,
    branch
FROM sales;

-- ------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------------- PRODUCT QUESTIONS ----------------------------------------

-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line) AS unique_products
FROM
	sales;
    
    
-- How much each payment method was used?
SELECT
	payment_method,
    COUNT(*) count_payment_method
FROM
	sales
GROUP BY payment_method
ORDER BY count DESC;


-- What is the frequency of each product line in sales?
SELECT
	product_line,
    COUNT(*) AS count_product_line
FROM
	sales
GROUP BY product_line
ORDER BY count_product_line DESC;


-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) total_revenue
FROM 
	sales
GROUP BY month_name
ORDER BY total_revenue DESC;


-- Display COGS for each month, starting from the highest?
SELECT
	month_name AS month,
	SUM(cogs) total_cogs
FROM 
	sales
GROUP BY month_name
ORDER BY total_cogs DESC;


-- Display product lines starting from the highest total revenue?
SELECT
	product_line,
    SUM(total) as total_revenue
FROM
	sales
GROUP BY product_line
ORDER BY total_revenue DESC;


-- Display cities starting from the highest total revenue?
SELECT
	branch,
	city,
    SUM(total) as total_revenue
FROM
	sales
GROUP BY city, branch
ORDER BY total_revenue DESC;


-- Display product lines starting from the highest VAT?
SELECT
	product_line,
    AVG(vat) as average_tax
FROM
	sales
GROUP BY product_line
ORDER BY average_tax DESC;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
ALTER TABLE sales
ADD COLUMN status_revenue_product VARCHAR(50);

UPDATE sales
JOIN (
    SELECT AVG(total) AS avg_total
    FROM sales
) AS avg_sale ON 1=1
SET status_revenue_product = (
    CASE
        WHEN total > avg_sale.avg_total THEN 'Good'
        ELSE 'Bad'
    END
);


-- Which branch has average products sold than average product sold across all branches?
SELECT
	branch,
    AVG(quantity) AS quantity_sold
FROM
	sales
GROUP BY branch
HAVING quantity_sold > (SELECT AVG(quantity) FROM sales);


-- What is the frequency distribution of product lines by gender, starting from the most frequent?
SELECT
	gender,
    product_line,
    COUNT(product_line) as count_frequency
FROM sales
GROUP BY gender, product_line
ORDER BY count_frequency DESC;


-- What is the average rating of each product line?
SELECT
	product_line,
	ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------------- SALES QUESTIONS ------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	day_name,
    time_of_day,
    COUNT(*) count
FROM sales
GROUP BY day_name, time_of_day
ORDER BY count DESC;


-- Can you display each customer type revenue starting from higher revenue?
SELECT
	customer_type,
    SUM(total) AS total_revenue_customer
FROM
	sales
GROUP BY customer_type
ORDER BY total_revenue_customer DESC;


-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(VAT), 2) AS total_vat
FROM
	sales
GROUP BY city
ORDER BY total_vat DESC;


-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    ROUND(AVG(VAT), 2) as average_VAT
FROM
	sales
GROUP BY customer_type
ORDER BY average_VAT DESC;


-- ------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------------- CUSTOMER QUESTIONS ---------------------------------------

-- What are the unique customer types in data?
SELECT
	DISTINCT customer_type
FROM
	sales;


-- What are the unique payment methods in the data?
SELECT
	DISTINCT payment_method
FROM
	sales;
    
    
-- What are frequency of each customer type?
SELECT
	customer_type,
    COUNT(*) AS count
FROM
	sales
GROUP BY
	customer_type
ORDER BY count DESC;


-- Can you display customer type that buys a lot in desc order?
SELECT
	customer_type,
    SUM(quantity) quantity,
    SUM(total) AS total_bought
FROM
	sales
GROUP BY customer_type
ORDER BY total_bought DESC;


-- What is the gender of most of the customers?
SELECT
    gender,
    COUNT(*) AS count
FROM
	sales
GROUP BY
	gender
ORDER BY count DESC;


-- What is the gender distribution per branch?
SELECT
	branch,
    gender,
    COUNT(*) AS count
FROM
	sales
GROUP BY branch, gender
ORDER BY branch;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
    AVG(rating) AS avg_rating
FROM
	sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
    branch,
    AVG(rating) AS avg_rating
FROM
	sales
GROUP BY time_of_day, branch
ORDER BY avg_rating DESC;


-- Which day of the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM
	sales
GROUP BY day_name
ORDER BY avg_rating DESC;


-- Which day of the week has the best average ratings per branch?
SELECT
	day_name,
    branch,
    AVG(rating) AS avg_rating
FROM
	sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------------------- END QUESTIONS --------------------------------------------
