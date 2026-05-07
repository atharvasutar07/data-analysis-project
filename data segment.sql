-- segment products into cost ranges and count how many products fall into each segment 
with product_segment as (
select 
product_key,
product_name,
product_cost,
case when product_cost < 100 THEN 'Below 100'
     when product_cost BETWEEN 100 and 500 THEN '100-500'
     when product_cost between 500 and 1000 then '500-1000'
     else 'above 1K'
end cost_range 
from gold.dim_products)

select 
cost_range,
count(product_key) as total_product
from product_segment
group by cost_range
order by total_product desc