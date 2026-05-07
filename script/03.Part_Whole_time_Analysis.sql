-- =========================================================
-- CATEGORY CONTRIBUTION TO OVERALL SALES
-- Identify which product categories contribute the most
-- to total business sales revenue
-- =========================================================

with category_sales as(
select
product_category,
sum(sales_amount) total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by product_category
)

select 
product_category,
sum(total_sales) over() overall_sales,
concat(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales;
