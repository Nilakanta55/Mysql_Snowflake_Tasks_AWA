-- Create a Database and Schema
CREATE DATABASE SWIGGYORDERS_DB;
USE SWIGGYORDERS_DB;


CREATE TABLE swiggy_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    restaurant_name VARCHAR(255) NOT NULL,
    order_date DATETIME NOT NULL,
    delivery_time DATETIME NOT NULL,
    delivery_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    delivery_status VARCHAR(50) NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,
    delivery_agent VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

load data local infile "C:/NewN/AWA/2 Snowflake/Assignment/A2/SwiggyOrders.csv"
into table swiggy_orders 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

show global variables like 'local_infile';
set global local_infile = 1;

select * from swiggy_orders;
select count(*) from swiggy_orders;

-- Easy Level:
-- 1.	Extracting Date Components:
-- o	Extract the year, month, and day from the order_date column in the Swiggy dataset.
SELECT 
    EXTRACT(year FROM order_date) AS order_year,
    EXTRACT(month FROM order_date) AS order_month,
    EXTRACT(day FROM order_date) AS order_day
FROM swiggy_orders;

/*
SELECT order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day
FROM swiggy_orders;
*/
-- 2.	Current Timestamp:
-- •	Get the current timestamp and compare it with the delivery_time.
SELECT delivery_time,
    CASE
        WHEN CURRENT_TIMESTAMP > delivery_time THEN 'Delivery time has passed.'
        WHEN CURRENT_TIMESTAMP < delivery_time THEN 'Delivery time is in the future.'
        ELSE 'Delivery time is now.'
    END AS delivery_status
FROM swiggy_orders
WHERE order_id = 2;

-- 3.	Date & Time Difference:
-- •	Calculate the number of days,hours,minutes,etc between the order_date and delivery_time and store it in respective columns.
-- Add columns to the table if they don't already exist
ALTER TABLE swiggy_orders
ADD COLUMN days_diff INT,
ADD COLUMN hours_diff INT,
ADD COLUMN minutes_diff INT,
ADD COLUMN seconds_diff INT;

-- Update the table with calculated differences
UPDATE swiggy_orders
SET 
    days_diff = timestampdiff(day, order_date, delivery_time),
    hours_diff = timestampdiff(hour, order_date, delivery_time),
    minutes_diff = timestampdiff(minute, order_date, delivery_time),
    seconds_diff = timestampdiff(second, order_date, delivery_time);
-- Verify  
SELECT * FROM swiggy_orders;

-- •	Add 45 minutes to the delivery_time and show the updated time.
SELECT order_id, customer_name, restaurant_name, order_date, delivery_time,
		ADDTIME(delivery_time, '00:45:00') AS updated_delivery_time, delivery_address, city, delivery_status, order_amount, delivery_agent
FROM swiggy_orders;

-- 4. Orders Placed in Specific Months:
-- •	Find all orders placed in September of any year.
SELECT * FROM swiggy_orders
WHERE EXTRACT(month FROM order_date) = 9;

-- Intermediate Level:
-- 4.	Time Zone Conversion:
-- o	Convert the delivery_time from UTC to a specific time zone (e.g., 'Asia/Kolkata').
SELECT delivery_time, 
	CONVERT_TZ(CONCAT(CURDATE(), ' ', delivery_time), '+00:00', 'Asia/Kolkata') AS delivery_time_kolkata
FROM swiggy_orders;

-- 5.	Orders on Specific Weekends:
-- •	Find all orders placed on a weekend (Saturday or Sunday).
SELECT order_id, order_date FROM swiggy_orders
WHERE DAYOFWEEK(order_date) IN (1, 7); -- 1 = Sunday, 7 = Saturday

-- Advanced Level:
-- 6.	Calculating Peak Hours:
-- o	Identify the peak delivery hours by extracting the hour from delivery_time and grouping by hour
SELECT 
    EXTRACT(HOUR FROM delivery_time) AS delivery_hour,
    COUNT(*) AS total_deliveries
FROM swiggy_orders
GROUP BY delivery_hour
ORDER BY total_deliveries DESC;

-- o	Identify which day of the week has the most deliveries.
SELECT DAYOFWEEK(order_date) AS day_of_week,
	   COUNT(*) AS total_deliveries
FROM swiggy_orders
GROUP BY DAYOFWEEK(order_date)
ORDER BY total_deliveries DESC
LIMIT 1;  -- This limits the result to the day with the most deliveries

-- 7.	Handling Daylight Saving Time:
-- o	Convert the delivery_time into a time zone that observes daylight saving time (e.g., 'America/New_York') and check if any orders fall during the daylight saving adjustment period.
SELECT delivery_time,
    CONVERT_TZ(CONCAT(CURDATE(), ' ', delivery_time), '+00:00', 'America/New_York') AS delivery_time_ny
FROM swiggy_orders;

-- 8.	Identify Late Deliveries: 
-- •	Find orders where the delivery took more than 1 hour.
SELECT * FROM swiggy_orders
WHERE TIMESTAMPDIFF(MINUTE, order_date, CONCAT(DATE(order_date), ' ', delivery_time)) >1;

-- 9.	Filtering Orders Between Two Date-Times:
-- o	Find all orders placed between specific date ranges, e.g., between '2023-09-01' and '2023-09-05' and orders placed between 5 PM and 7 PM both for those dates included and without those date too irrespective of dates.
-- Orders Placed Between Specific Date Ranges (e.g., ‘2023-09-01’ and ‘2023-09-05’)
SELECT * FROM swiggy_orders
WHERE order_date BETWEEN '2023-09-01' AND '2023-09-05';

-- Find Orders Placed Between 5 PM and 7 PM for Specific Dates
SELECT *FROM swiggy_orders
WHERE order_date BETWEEN '2023-09-01' AND '2023-09-05'
AND TO_CHAR(order_date, 'HH24:MI') BETWEEN '17:00' AND '19:00';

-- Orders Placed Between 5 PM and 7 PM Irrespective of Dates
SELECT * FROM swiggy_orders
WHERE TO_CHAR(order_date, 'HH24:MI') BETWEEN '17:00' AND '19:00';

-- 10.	Handling Leap Years:
-- o	Find orders placed on February 29th (during leap years).
SELECT * FROM swiggy_orders
WHERE EXTRACT(MONTH FROM order_date) = 2
  AND EXTRACT(DAY FROM order_date) = 29;

-- 11.	Timestamp Arithmetic with Time Zones:
-- o	Calculate the time difference between the order time in 'Asia/Kolkata' and 'America/Los_Angeles'.
SELECT @@global.time_zone, @@session.time_zone;
DESCRIBE swiggy_orders;
SELECT order_date FROM swiggy_orders LIMIT 5;

SELECT CONVERT_TZ('2024-09-15 12:00:00', 'Asia/Kolkata', 'America/Los_Angeles');


SELECT order_id, order_date,
    CONVERT_TZ(order_date, 'Asia/Kolkata', 'America/Los_Angeles') AS order_time_LA,
    TIMESTAMPDIFF(HOUR, order_date, CONVERT_TZ(order_date, 'Asia/Kolkata', 'America/Los_Angeles')) AS time_difference_hours
FROM swiggy_orders;

-- 12.	Finding the Most Recent Order:
-- o	Retrieve the most recent order placed in the last 7 days
SELECT * FROM swiggy_orders
WHERE order_date >= NOW() - INTERVAL 7 DAY
ORDER BY order_date DESC
LIMIT 1;

-- Expert Level:
-- 13.	Calculate Average Delivery Time per City:
SELECT city,
    AVG(TIMESTAMPDIFF(MINUTE, order_date, delivery_time)) AS avg_delivery_time_minutes
FROM swiggy_orders
GROUP BY city;

-- 14.	Finding Busiest Days by City:
-- •	Identify which day of the week has the highest number of orders for each city.
SELECT city,
    DAYNAME(order_date) AS day_of_week,
    COUNT(*) AS order_count
FROM swiggy_orders
GROUP BY city, day_of_week
ORDER BY city, order_count DESC;
    
-- 15.	Delayed Deliveries Based on Peak Hours:
-- •	Identify orders that took longer during peak hours (5 PM - 8 PM).
SELECT order_id, order_date, delivery_time,
    TIMESTAMPDIFF(MINUTE, order_date, delivery_time) AS delivery_duration_minutes
FROM swiggy_orders
WHERE HOUR(order_date) BETWEEN 17 AND 20 AND TIMESTAMPDIFF(MINUTE, order_date, delivery_time) > (SELECT AVG(TIMESTAMPDIFF(MINUTE, order_date, delivery_time)) FROM swiggy_orders)
ORDER BY delivery_duration_minutes DESC;
    
-- 16.	Orders with Week-to-Week Growth:
-- •	Calculate week-on-week growth of orders.
SELECT 
    YEAR(order_date) AS order_year,
    WEEK(order_date) AS order_week,
    COUNT(*) AS order_count
FROM swiggy_orders
GROUP BY order_year, order_week
ORDER BY order_year, order_week;


-- 17.	Finding Orders Affected by Public Holidays:
-- •	Identify orders placed on specific public holidays (e.g., New Year's Day, Diwali)
SELECT o.order_id, o.order_date, ph.holiday_name
FROM swiggy_orders o
JOIN public_holidays ph
ON o.order_date = ph.holiday_date
WHERE ph.holiday_name IN ('New Year\'s Day', 'Diwali');

WITH public_holidays AS (
    SELECT '2024-01-01'::DATE AS holiday_date, 'New Year\'s Day' AS holiday_name
    UNION ALL
    SELECT '2024-11-12'::DATE AS holiday_date, 'Diwali' AS holiday_name
    -- Add more holidays as needed
)
SELECT o.order_id, o.order_date, ph.holiday_name
FROM swiggy_orders o
JOIN public_holidays ph
ON o.order_date = ph.holiday_date;