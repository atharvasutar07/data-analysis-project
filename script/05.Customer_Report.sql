/*
========================================================================
Customer Report
========================================================================
Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
================================================================= 
*/

create view gold.report_customers as
with base_query as(
select 
f.order_number,
f.product_key,
f.sales_amount,
f.quantity,
f.order_date,
c.row_id,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
timestampdiff(year, c.birthdate, NOW()) AGE
from gold.fact_sales f
left join gold.dim_customers c
on c.row_id= f.customer_id
where order_date IS not null
)

,customer_aggeration as (
	select 
	row_id,
	customer_number,
	customer_name,
	age,
	count(distinct order_number) as total_order,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_products,
	max(order_date) as last_orderdate,
	timestampdiff(month,min(order_date), max(order_date)) as lifespan
	from base_query
	group by 
		row_id,
		customer_number,
		customer_name,
		age
)
select 
row_id,
customer_number,
customer_name,
age,
case when age < 20 THEN 'under 20'
	 when age Between 20 and 29 then '20-29'
     when age between 30 and 39 then '30-39'
     when age between 40 and 49 then '40-49'
     else '50-above'
end age_group,
CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
END AS segment_customer,
last_orderdate,
timestampdiff(month, last_orderdate, now()) as recency,
total_order,
total_sales,
total_quantity,
total_products,
lifespan,
--  average order value(AVO)
case when total_sales = 0 THEN 0
	 else total_sales / total_order
END as avg_order_value,

--  avg monthly spend 
case when lifespan = 0 THEN total_sales
	 else total_sales / lifespan 
END as monthly_spend
from customer_aggeration
  
