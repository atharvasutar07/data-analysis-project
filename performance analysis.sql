/*analyze the yearly performance of products by comparing their sales 
to both the avarage sales performance of product and the perious year's sales
*/
with yearly_product_sales AS(
select
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where f.order_date is not null
group by 
year(f.order_date),
p.product_name 
)

select 
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
CASE when current_sales - avg(current_sales) over(partition by product_name) > 0 Then 'Above avg'
	 when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below avg'
     else 'avg'
END avg_change,
lag(current_sales) over (partition by product_name order BY order_year) py_sales,
current_sales - lag(current_sales) over (partition by product_name order BY order_year) as diff_py_sales,
case when current_sales -lag(current_sales) over (partition by product_name order BY order_year) > 0 Then 'Increasing'
     when current_sales -lag(current_sales) over (partition by product_name order BY order_year) < 0 Then 'decreasing'
	 else 'no change'
End py_change 
from yearly_product_sales
order by product_name, order_year