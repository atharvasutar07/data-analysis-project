/*
======================================================================================
Product Report
======================================================================================
Purpose:
- This report consolidates key product metrics and behaviors.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
========================================================================================
*/
create view gold.product_report AS
with essential_field as(
select
f.order_number,
f.order_date,
f.product_key,
f.customer_id,
f.sales_amount,
f.quantity,
p.product_name,
p.product_category,
p.product_subcategory,
p.product_cost
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null 
),
product_aggregation as (
select 
product_key,
product_name,
product_category,
product_subcategory,
product_cost,
timestampdiff(month, min(order_date) , max(order_date)) as lifespan,
max(order_date) as last_sales_date,
count(distinct order_number) as total_orders,
count(distinct customer_id) as total_customers,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
round(avg(cast(sales_amount as float) / NULLIF(quantity,0)),1) as avg_selling_price
from essential_field
group by 
product_key,
product_name,
product_category,
product_subcategory,
product_cost
)

select 
product_key,
product_name,
product_category,
product_subcategory,
product_cost,
last_sales_date,
timestampdiff(month,last_sales_date,now()) as recency_in_months,
case 
    when total_sales > 50000 THEN 'High performer'
    when total_sales >= 10000 THEN 'mid-range'
    else 'low-performer'
END as product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- AOR
case 
   when total_orders = 0 then 0
else total_sales / total_orders
END avg_order_revenue,

-- AMR
case
   when lifespan = 0 then total_sales
   else total_sales / lifespan
END avg_month_revenue
from product_aggregation
