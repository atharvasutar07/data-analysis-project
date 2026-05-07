/*
Analyzes how key business metrics such as sales, revenue,
or customer activity change over a specific period to identify 
trends, growth patterns, and seasonal behavior.
*/

-- Analyze yearly and monthly sales performance trends
select 
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_id) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group  by year(order_date), Month(order_date)
order by year(order_date), Month(order_date);

-- Monthly sales trend analysis using formatted date
select 
DATE_FORMAT(order_date, '%Y-%m-01') AS order_month,
sum(sales_amount) as total_sales,
count(distinct customer_id) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group  by order_month
order by order_month
