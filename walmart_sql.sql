CREATE TABLE IF NOT EXISTS sales(
  invoice_id VARCHAR(30) NOT NULL PRIMARY KEY, 
  branch VARCHAR(5) NOT NULL, 
  city VARCHAR(30) NOT NULL, 
  customer_type VARCHAR(30) NOT NULL, 
  gender VARCHAR(30) NOT NULL, 
  product_line VARCHAR(100) NOT NULL, 
  unit_price DECIMAL(10, 2) NOT NULL, 
  quantity INT NOT NULL, 
  tax_pct FLOAT(6, 4) NOT NULL, 
  total DECIMAL(12, 4) NOT NULL, 
  date DATETIME NOT NULL, 
  time TIME NOT NULL, 
  payment VARCHAR(15) NOT NULL, 
  cogs DECIMAL(10, 2) NOT NULL, 
  gross_margin_pct FLOAT(11, 9), 
  gross_income DECIMAL(12, 4), 
  rating FLOAT(2, 1)
);
select 
  * 
from 
  sales;
-- Feature engineering -- 

/*
Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening.
This will help answer the question on which part of the day most sales are made
*/
select 
  time, 
  (
    CASE when `time` between "00:00:00" 
    and "12:00:00" then "Morning" when `time` between "12:01:00" 
    and "16:00:00" then "Afternoon" else "Evening" END
  ) 
from 
  sales;
alter table 
  sales 
add 
  column time_of_day varchar(20);
update 
  sales 
set 
  time_of_day = (
    CASE when `time` between "00:00:00" 
    and "12:00:00" then "Morning" when `time` between "12:01:00" 
    and "16:00:00" then "Afternoon" else "Evening" END
  );
SET 
  SQL_SAFE_UPDATES = 0;
/* 
Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
This will help answer the question on which week of the day each branch is busiest.
*/
select 
  date, 
  dayname(date) 
from 
  sales;
alter table 
  sales 
add 
  column day_name varchar(20);
update 
  sales 
set 
  day_name = dayname(date);
/* 

Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
Help determine which month of the year has the most sales and profit.

*/
SELECT 
  date, 
  monthname(date) 
FROM 
  sales;
alter table 
  sales 
add 
  column month_name varchar(20);
update 
  sales 
set 
  month_name = monthname(date);
-- --
-- Generic --

/* 
How many unique cities does the data have?
*/
select 
  distinct city 
from 
  sales;
/*In which city is each branch?*/
select 
  distinct branch 
from 
  sales;
select 
  distinct city, 
  branch 
from 
  sales;
-- -- 
-- Product -- 

/* 
How many unique product lines does the data have?
*/
select 
  distinct product_line 
from 
  sales;
select 
  count(distinct product_line) as total_unique_products 
from 
  sales;
/* 
What is the most common payment method?
*/
select 
  payment, 
  count(payment) as cnt 
from 
  sales 
group by 
  payment 
order by 
  cnt desc;
/* 
What is the most selling product line?
*/
select 
  product_line, 
  count(product_line) as cnt 
from 
  sales 
group by 
  product_line 
order by 
  cnt desc;
/*What is the total revenue by month? */
select 
  month_name as month_, 
  sum(total) as total_revenue 
from 
  sales 
group by 
  month_ 
order by 
  total_revenue desc;
/*What month had the largest COGS? */
select 
  month_name as month_, 
  sum(cogs) as max_cogs 
from 
  sales 
group by 
  month_ 
order by 
  max_cogs desc;
/*What product line had the largest revenue?
 */
select 
  product_line as products, 
  sum(total) as largest_revenue 
from 
  sales 
group by 
  products 
order by 
  largest_revenue desc;
/*What is the city with the largest revenue?
 */
select 
  city, 
  sum(total) as largest_revenue 
from 
  sales 
group by 
  city 
order by 
  largest_revenue desc;
/*What product line had the largest VAT?
 */
select 
  product_line, 
  avg(tax_pct) as largest_vat 
from 
  sales 
group by 
  product_line 
order by 
  largest_vat desc;
/* Fetch each product line and add a column to those product line
showing "Good", "Bad". Good if its greater than average sales*/
select 
  product_line, 
  case when avg(quantity) < 6 then "good" else "bad" end as performance 
from 
  sales 
group by 
  product_line;
/*
Which branch sold more products than average product sold?*/
select 
  branch, 
  sum(quantity) 
from 
  sales 
group by 
  branch 
having 
  sum(quantity) > (
    select 
      avg(quantity) 
    from 
      sales
  );
/*What is the most common product line by gender?*/
select 
  gender, 
  product_line, 
  count(gender) as total_count 
from 
  sales 
group by 
  gender, 
  product_line 
order by 
  total_count desc;
/*What is the average rating of each product line?*/
select 
  round(
    avg(rating), 
    2
  ) as avg_rating, 
  product_line 
from 
  sales 
group by 
  product_line 
order by 
  avg_rating desc;
-- ------------------------- --    
-- SALES-- 
-- SALES --

/*Number of sales made in each time of the day per weekday */
select 
  time_of_day, 
  count(*) as total_sales 
from 
  sales 
group by 
  time_of_day 
order by 
  total_sales desc;
select 
  time_of_day, 
  count(*) as total_sales 
from 
  sales 
where 
  day_name = "wednesday" 
group by 
  time_of_day 
order by 
  total_sales desc;
/* Which of the customer types brings the most revenue?*/
select 
  customer_type, 
  sum(total) as total_count 
from 
  sales 
group by 
  customer_type 
order by 
  total_count desc;
/* Which city has the largest tax percent/ VAT (Value Added Tax)?
*/
select 
  city, 
  avg(tax_pct) as vat 
from 
  sales 
group by 
  city 
order by 
  vat desc;
/* Which customer type pays the most in VAT?
*/
select 
  customer_type, 
  avg(tax_pct) as vat 
from 
  sales 
group by 
  customer_type 
order by 
  vat desc;
-- -------------------------------------- --    
-- CUSTOMER --
-- -------------------------------------- --    

/* How many unique customer types does the data have?
*/
select 
  distinct customer_type 
from 
  sales;
/* How many unique payment methods does the data have?*/
select 
  distinct payment 
from 
  sales;
/* What is the most common customer type? */
select 
  customer_type, 
  count(*) as total_cnt 
from 
  sales 
group by 
  customer_type 
order by 
  total_cnt;
/* Which customer type buys the most? */
select 
  customer_type, 
  count(*) as total_cnt 
from 
  sales 
group by 
  customer_type 
order by 
  total_cnt desc;
/* What is the gender of most of the customers? */
select 
  gender, 
  count(gender) as gender_count 
from 
  sales 
group by 
  gender 
order by 
  gender_count desc;
/* What is the gender distribution per branch?
*/
select 
  gender, 
  count(gender) as gender_count 
from 
  sales 
where 
  branch = "b" 
group by 
  gender 
order by 
  gender_count desc;
/* Which time of the day do customers give most ratings?
 */
select 
  time_of_day, 
  avg(rating) as avg_rating 
from 
  sales 
group by 
  time_of_day 
order by 
  avg_rating desc;
/* Which time of the day do customers give most ratings per branch? */
select 
  time_of_day, 
  avg(rating) as avg_rating 
from 
  sales 
where 
  branch = "b" 
group by 
  time_of_day 
order by 
  avg_rating desc;
/* Which day of the week has the best avg ratings? */
select 
  day_name, 
  avg(rating) as avg_rating 
from 
  sales 
group by 
  day_name 
order by 
  avg_rating desc;
/* Which day of the week has the best average ratings per branch?
 */
select 
  day_name, 
  round(
    avg(rating), 
    2
  ) as avg_rating 
from 
  sales 
where 
  branch = "b" 
group by 
  day_name 
order by 
  avg_rating desc;
