-- calculate the total sales per month 
-- and the running total of sales over time
 
select 
order_month,
total_sales,
sum(total_sales) over (order by order_month) as running_total_sales,
sum(avg_price) over (order by order_month) as moving_total_sales
from
(
select 
date_format(order_date, '%Y-01-01') as order_month,
sum(sales_amount ) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by order_month
)t
