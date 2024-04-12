create database if not exists walmartSales;
USE walmartSales;
CREATE TABLE IF NOT EXISTS sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- after null values now we do feature engineering to add different columns:
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

SELECT date, DAYNAME(date) FROM sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = DAYNAME(date);

SELECT date, MONTHNAME(date) FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(date);

-- queries solutions:-----------------------------------------------------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- How many unique product lines does the data have?
SELECT
	DISTINCT product_line
FROM sales;

-- What is the most selling product line
SELECT
    SUM(quantity) as total_quantity,
    product_line
FROM sales
GROUP BY product_line
ORDER BY total_quantity DESC
LIMIT 1;


-- What is the top 5 most selling product line
SELECT
    SUM(quantity) as total_quantity,
    product_line
FROM sales
GROUP BY product_line
ORDER BY total_quantity DESC
LIMIT 5;


-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue;

-- What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs;

-- Product line and its total revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- City and total revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;

-- Which product line has how much VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- average quantity
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

-- product line and its remarks
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
    branch, 
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- how much is the count of each product line for each gender:
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
    customer_type,
    COUNT(*) as customer_type_cnt
FROM sales
GROUP BY customer_type
ORDER BY customer_type_cnt DESC
LIMIT 1;


-- What is the gender of most of the customers?
SELECT
    gender,
    COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC
LIMIT 1;

-- What is the gender distribution per branch?
SELECT
    gender,
    SUM(CASE WHEN branch = 'A' THEN 1 ELSE 0 END) AS branch_a_cnt,
    SUM(CASE WHEN branch = 'B' THEN 1 ELSE 0 END) AS branch_b_cnt,
    SUM(CASE WHEN branch = 'C' THEN 1 ELSE 0 END) AS branch_c_cnt
FROM sales
WHERE branch IN ('A', 'B', 'C')
GROUP BY gender
ORDER BY gender;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- What avg ratings for each day?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
    branch,
    day_name,
    AVG(rating) AS average_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, average_rating DESC;


-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
    city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC
LIMIT 1;


-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax  desc
limit 1;

-- Average Transaction Value per Customer Type:
SELECT
    customer_type,
    AVG(total) AS avg_transaction_value
FROM sales
GROUP BY customer_type;

-- Most Common Payment Method per City:
SELECT
    city,
    payment,
    COUNT(*) AS payment_count
FROM sales
GROUP BY city, payment
ORDER BY payment_count DESC;

-- Product Line Sales Growth (Month-over-Month):
SELECT
    product_line,
    MONTH(date) AS month,
    SUM(total) AS monthly_sales
FROM sales
GROUP BY product_line, month
ORDER BY product_line, month;

-- Average Gross Margin Percentage per Product Line:
SELECT
    product_line,
    AVG(gross_margin_pct) AS avg_gross_margin
FROM sales
GROUP BY product_line
ORDER BY avg_gross_margin DESC;

-- Payment Method Preferences by Customer Type:
SELECT
    customer_type,
    payment,
    COUNT(*) AS payment_count
FROM sales
GROUP BY customer_type, payment
ORDER BY customer_type, payment_count DESC;

-- Average Rating per Gender:
SELECT
    gender,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY gender;

-- Monthly Sales Growth Percentage excluding the first month:
SELECT
    MONTH(date) AS month,
    SUM(total) AS monthly_sales,
    LAG(SUM(total)) OVER (ORDER BY MONTH(date)) AS previous_month_sales,
    CASE
        WHEN LAG(SUM(total)) OVER (ORDER BY MONTH(date)) IS NOT NULL
        THEN ROUND((SUM(total) - LAG(SUM(total)) OVER (ORDER BY MONTH(date))) / LAG(SUM(total)) OVER (ORDER BY MONTH(date)) * 100, 2)
        ELSE NULL
    END AS sales_growth_percentage
FROM sales
GROUP BY month
ORDER BY month;




