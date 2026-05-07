/* =========================================================
   PRODUCT COST SEGMENTATION ANALYSIS
   Segment products into different cost ranges and count
   how many products fall into each category
   ========================================================= */

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
order by total_product desc;

/* =========================================================
   CUSTOMER SEGMENTATION ANALYSIS
   Group customers into segments based on:
   1. Customer lifespan
   2. Total spending behavior

   Segments:
   - VIP     : Customers with at least 12 months history
               and spending above 5000
   - Regular : Customers with at least 12 months history
               and spending 5000 or less
   - New     : Customers with lifespan below 12 months
   ========================================================= */

WITH customer_segment AS (
    SELECT 
        c.customer_id,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    JOIN gold.dim_customers c
        ON f.customer_id = c.customer_id
    GROUP BY c.customer_id
)

SELECT
    segment_customer,
    COUNT(customer_id) AS total_customers
FROM (
    SELECT 
        customer_id,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'regular'
            ELSE 'new'
        END AS segment_customer
    FROM customer_segment
) t
GROUP BY segment_customer
ORDER BY total_customers DESC;
  

