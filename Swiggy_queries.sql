-- Databricks notebook source
SHOW TABLES FROM workspace.swiggy

-- COMMAND ----------

select * from workspace.swiggy.swiggy_dim_customer;

-- COMMAND ----------

SELECT * FROM workspace.swiggy.swiggy_dim_restaurant_product

-- COMMAND ----------

SELECT * FROM workspace.swiggy.swiggy_dim_campaign

-- COMMAND ----------

SELECT * FROM workspace.swiggy.swiggy_dim_coupon;

-- COMMAND ----------

  SELECT * FROM workspace.swiggy.swiggy_dim_geo;

-- COMMAND ----------

SELECT * FROM workspace.swiggy.swiggy_fact_transactions;

-- COMMAND ----------

-- A1) Preview the latest 20 transactions ordered by date and time.

SELECT
*
FROM workspace.swiggy.swiggy_fact_transactions
ORDER BY (transaction_date, transaction_time) DESC
LIMIT 20;

-- COMMAND ----------

-- A2) Find the minimum and maximum transaction_date in the fact table.

SELECT
	MIN(transaction_date) AS Minimum_transaction_date,
	MAX(transaction_date) AS Maximum_transaction_date

FROM workspace.swiggy.swiggy_fact_transactions;

-- COMMAND ----------

-- A3) Show the total number of orders per city in descending order.

SELECT
city,
SUM((quantity)) AS Total_orders
FROM workspace.swiggy.swiggy_fact_transactions
GROUP BY city
ORDER BY Total_orders desc;

-- COMMAND ----------

-- A4) Calculate the percentage of orders where a coupon was used order by city.

SELECT
city,
count(transaction_id) as Total_orders,
Round(100 * (COUNT(CASE WHEN coupon_used_flag = 'true' THEN true END)) / count(*),2) AS coupon_used,
ROUND((COUNT(CASE WHEN coupon_used_flag = 'false' THEN false END) * 100) / count(*),2) AS coupon_not_used
FROM workspace.swiggy.swiggy_fact_transactions
GROUP BY city;


-- COMMAND ----------

-- A5) Find the average delivery time (delivery_minutes) by city.

SELECT
city,
AVG(delivery_minutes) as Avg_delivery_time
FROM workspace.swiggy.swiggy_fact_transactions
GROUP BY city
Order by Avg_delivery_time DESC;

-- COMMAND ----------

-- B1) Calculate monthly net revenue by city.
--     Output columns: city, year_month, net_revenue  

SELECT
  City,
  DATE_FORMAT(transaction_date, 'yyyy-MM') as year_month,
  SUM(net_amount) AS monthly_net_amount
FROM workspace.swiggy.swiggy_fact_transactions
GROUP BY city, year_month
ORDER BY city, year_month DESC;

-- COMMAND ----------

-- B2) For each month, calculate:
--     • total gross amount
--     • total coupon discount
--     • percentage of coupon discount over gross amount

SELECT
  DATE_FORMAT(transaction_date, 'yyyy-MM') as year_month,
  city,
  SUM(gross_amount) AS Gross_amount_monthly,
  SUM(coupon_discount_amount) Coupon_discount_amount_monthly,
  CONCAT(ROUND(((SUM(coupon_discount_amount) / SUM(gross_amount)) *100), 3), '%') AS discount_percentage
  from workspace.swiggy.swiggy_fact_transactions
GROUP BY year_month, city
ORDER BY year_month, city DESC;

-- COMMAND ----------

-- B3) For each month, calculate:
--     • total discount amount
--     • total membership benefit amount
--     • percentage share of membership benefit in total discount

SELECT
  DATE_FORMAT(transaction_date, 'yyyy-MM') AS year_month,
  city,
  SUM(total_discount_amount) AS Total_monthly_discount,
  SUM(membership_benefit_amount) AS Total_membership_benefit,
  CONCAT(ROUND(((Total_membership_benefit / Total_monthly_discount) * 100), 3), '%') AS memberships_benefit_monthly

FROM workspace.swiggy.swiggy_fact_transactions
GROUP BY year_month, city
ORDER BY year_month, city desc;

-- COMMAND ----------

-- B4) Identify the top 20 customers by net spending in the last 30 days.
--     Output: customer_id, total_net_amount, total_orders

--Ans

-- net_spend = gross_amount - total_amount_discount i.e total_net_amoun

SELECT
ft.customer_id,
SUM(ft.net_amount) AS total_net_amount,
COUNT(ft.transaction_id) AS total_orders

FROM workspace.swiggy.swiggy_fact_transactions AS ft

WHERE transaction_date <=current_date()- INTERVAL 30 DAYS
GROUP BY ft.customer_id
ORDER BY total_net_amount DESC
limit 20;


-- COMMAND ----------

-- Calculate the monthly repeat rate:
--     • Active customers per month
--     • Repeat customers (2+ orders in same month)
--     • Repeat rate percentage

SELECT
	DATE_FORMAT(transaction_date, 'yyyy-MM') AS year_month,
	city,
	COUNT(DISTINCT customer_id) AS active_customers
From workspace.swiggy.swiggy_fact_transactions
GROUP BY year_month, city
ORDER BY year_month ,city DESC;

-- COMMAND ----------

--- Calculate delivery success rate by city and device type.

SELECT
city,
device_type,
COUNT(delivery_success_flag) AS Delivery_Success_Rate
from workspace.swiggy.swiggy_fact_transactions
WHERE delivery_success_flag = 'True'
GROUP BY city, device_type
order by city desc;

-- COMMAND ----------


-- B8) Identify the worst 50 deliveries based on:
--     • Failed deliveries OR
--     • Very high delivery time
--     Sort with worst cases first.

SELECT *
FROM workspace.swiggy.swiggy_fact_transactions
WHERE (NOT delivery_success_flag)
 OR
 delivery_minutes >=(
  select PERCENTILE_APPROX(delivery_minutes, 0.90)
  FROM workspace.swiggy.swiggy_fact_transactions
 )
ORDER BY delivery_success_flag ASC, delivery_minutes DESC  
LIMIT 50;


-- COMMAND ----------

-- Compare average delivery time for raining vs non-raining orders by city.

SELECT
city,
raining_flag,
COUNT(*) as orders,
round(AVG(delivery_minutes),3) as Avg_delivery_minutes
from workspace.swiggy.swiggy_fact_transactions
GROUP BY city, raining_flag
ORDER BY city, raining_flag;






-- COMMAND ----------

-- B8) Identify the worst 50 deliveries based on:
--     • Failed deliveries OR
--     • Very high delivery time
--     Sort with worst cases first.

select
transaction_id,
customer_id,
city,
delivery_success_flag,
delivery_minutes,
surge_flag,
raining_flag,
net_amount
from workspace.swiggy.swiggy_fact_transactions
WHERE (NOT delivery_success_flag) or
      delivery_minutes >= (
              select percentile_approx(delivery_minutes, 0.95)
              from workspace.swiggy.swiggy_fact_transactions
)
ORDER BY delivery_success_flag ASC, delivery_minutes DESC
limit 50;







-- COMMAND ----------

-- B9) Calculate Campaign CTR (Click-Through Rate) by campaign_id.
--     Consider only exposed orders.

SELECT
campaign_id,
city,
COUNT(*) AS exposed_orders,
SUM(CASE WHEN ad_clicked_flag THEN 1 ELSE 0 END) AS clicked_orders,
CONCAT(ROUND(100 * SUM(CASE WHEN ad_clicked_flag THEN 1 ELSE 0 END) / NULLIF(COUNT(*) , 0),2), '%') AS CTR_precentage
FROM workspace.swiggy.swiggy_fact_transactions
WHERE campaign_exposed_flag = 'TRUE'
GROUP BY campaign_id, city


-- COMMAND ----------

-- B10) Compare average net order value for:
--      • Campaign exposed orders
--      • Non-exposed orders
--      Split by city.

SELECT
city,
campaign_exposed_flag,
COUNT(*) as Total_orders,
round(AVG(net_amount), 2) as Avg_net_amount
from workspace.swiggy.swiggy_fact_transactions
Group by city, campaign_exposed_flag
order by Total_orders desc;

-- COMMAND ----------

-- Create an enriched order view by joining:
--     fact_transactions with:
--     • dim_customer
--     • dim_geo
--     • dim_restaurant_product
--     • dim_coupon
--     • dim_campaign
--     Include key customer, geo, product, coupon, and campaign attributes.

select
f.transaction_id,
f.transaction_date,
f.transaction_time,
f.city AS order_city,
f.device_type,
f.customer_id,
dc.customer_name,
dc.gender,
dc.age,
dc.signup_date,
dc.membership_tier AS customer_membership_tier,
f.restaurant_product_id,
drp.restaurant_name,
drp.product_name,
drp.cuisine_tag,
drp.list_price,
f.geo_id,
dg.city AS geo_city,
dg.state AS geo_state,
dg.pincode,
f.coupon_used_flag,
f.coupon_id,
dco.coupon_name,
dco.discount_type,
dco.discount_value,
dco.max_discount,
dco.min_order,
f.campaign_exposed_flag,
f.campaign_id,
dca.campaign_name,
dca.channel AS campaign_channel,
dca.objective AS campaign_objective,
f.gross_amount,
f.coupon_discount_amount,
f.membership_benefit_amount,
f.total_discount_amount,
f.net_amount,
f.delivery_success_flag,
f.delivery_minutes,
f.rating
FROM workspace.swiggy.swiggy_fact_transactions  as f
LEFT JOIN workspace.swiggy.swiggy_dim_customer as dc
ON f.customer_id = dc.customer_id
LEFT JOIN workspace.swiggy.swiggy_dim_geo as dg
ON f.geo_id = dg.geo_id
LEFT JOIN workspace.swiggy.swiggy_dim_restaurant_product as drp
ON f.restaurant_product_id = drp.restaurant_product_id
LEFT JOIN workspace.swiggy.swiggy_dim_coupon as dco
ON f.coupon_id = dco.coupon_id
LEFT JOIN workspace.swiggy.swiggy_dim_campaign as dca
ON f.campaign_id = dca.campaign_id
LIMIT 50;



-- COMMAND ----------

-- Data Quality Check:
--     Identify orphan fact records (missing dimension matches) for:
--     • Customer
--     • Geo
--     • Restaurant Product
--     • Coupon (only when coupon_used_flag = 1)
--     • Campaign (only when campaign_exposed_flag = 1)

SELECT
'dim_customer' as  dim_name,
COUNT(*) AS orphan_fact_records
from workspace.swiggy.swiggy_fact_transactions as f
LEFT JOIN
workspace.swiggy.swiggy_dim_customer as d
ON d.customer_id = f.customer_id
WHERE d.customer_id IS NULL

UNION ALL

SELECT
'dim_geo' as  dim_name,
COUNT(*)
from workspace.swiggy.swiggy_fact_transactions as f
LEFT JOIN
workspace.swiggy.swiggy_dim_geo as g
ON g.geo_id = f.geo_id
WHERE g.geo_id IS NULL

UNION ALL

SELECT
'dim_restaurant_product' as dim_restaurant_product,
COUNT(*)
from workspace.swiggy.swiggy_fact_transactions as f
LEFT JOIN
workspace.swiggy.swiggy_dim_restaurant_product as r
ON r.restaurant_product_id = f.restaurant_product_id
WHERE r.restaurant_product_id IS NULL

UNION ALL

SELECT
'dim_restaurant_product' as dim_restaurant_product,
COUNT(*)
from workspace.swiggy.swiggy_fact_transactions as f
LEFT JOIN
workspace.swiggy.swiggy_dim_restaurant_product as r
ON r.restaurant_product_id = f.restaurant_product_id
WHERE r.restaurant_product_id IS NULL

UNION ALL 

SELECT 'dim_coupon (coupon_used_flag=true)' AS dim_name, COUNT(*)
FROM workspace.swiggy.swiggy_fact_transactions f
LEFT JOIN 
workspace.swiggy.swiggy_dim_coupon d
ON f.coupon_id = d.coupon_id
WHERE f.coupon_used_flag AND d.coupon_id IS NULL

UNION ALL

SELECT 'dim_campaign (campaign_exposed_flag=true)' AS dim_name, COUNT(*)
FROM workspace.swiggy.swiggy_fact_transactions f
LEFT JOIN 
workspace.swiggy.swiggy_dim_campaign d 
ON f.campaign_id = d.campaign_id
WHERE f.campaign_exposed_flag AND d.campaign_id IS NULL;

-- COMMAND ----------

--C3)--Find the top 5 cuisines by net revenue for each city and month.
--     Use cuisine_tag from the restaurant product dimension.
with base as (
SELECT
f.city,
DATE_FORMAT(f.transaction_date, 'yyyy-MM') AS year_month,
drp.cuisine_tag,
SUM(f.net_amount) AS net_revenue,
COUNT(*) as Orders
from workspace.swiggy.swiggy_fact_transactions AS f
JOIN
workspace.swiggy.swiggy_dim_restaurant_product AS drp
ON
f.restaurant_product_id = drp.restaurant_product_id
GROUP BY f.city, DATE_FORMAT(f.transaction_date, 'yyyy-MM'), drp.cuisine_tag
),

ranked AS (
  select
  *,
  ROW_NUMBER() OVER(PARTITION BY city, year_month ORDER BY net_revenue DESC) AS rn
  FROM base
)

SELECT
city,
year_month,
cuisine_tag,
round(net_revenue, 2) As net_revenue,
orders
FROM ranked
WHERE rn <=5
ORDER BY year_month, city, rn



-- COMMAND ----------

--  Create a restaurant leaderboard:
--     • Top restaurants by net revenue
--     • Split by city
--     • Only include orders from the last 60 days

SELECT
f.city,
drp.restaurant_name,
COUNT(*) AS orders,
ROUND(SUM(f.net_amount),3) AS net_revenue,
ROUND(AVG(f.delivery_minutes),2) as Avg_delivery_minutes
from workspace.swiggy.swiggy_fact_transactions f
JOIN
workspace.swiggy.swiggy_dim_restaurant_product as drp
WHERE f.transaction_date >= DATE_SUB(current_date(), 60)
GROUP BY f.city, drp.restaurant_name
ORDER BY f.city, net_revenue DESC;

-- COMMAND ----------

--Perform coupon performance analysis:
--     For each coupon:
--     • Number of orders
--     • Total coupon burn
--     • Average gross amount
--     • Average net amount

SELECT
dco.coupon_id,
dco.coupon_name,
dco.discount_type,
dco.discount_value,
dco.max_discount,
dco.min_order,
COUNT(*) AS coupon_orders,
ROUND(SUM(f.coupon_discount_amount), 2) AS total_coupon_burn,
ROUND(AVG(f.gross_amount), 2) AS avg_gross_with_coupon,
ROUND(AVG(f.net_amount), 2) AS avg_net_with_coupon
FROM workspace.swiggy.swiggy_fact_transactions f
JOIN
workspace.swiggy.swiggy_dim_coupon dco
ON
f.coupon_id = dco.coupon_id
WHERE f.coupon_used_flag
GROUP BY
dco.coupon_id, dco.coupon_name, dco.discount_type,
dco.discount_value, dco.max_discount, dco.min_order
ORDER BY total_coupon_burn DESC;


-- COMMAND ----------

-- Geo drill-down analysis:
--     Using state and pincode from dim_geo, calculate:
--     • Orders
--     • Net revenue
--     • Average delivery time
--     • Delivery success rate

SELECT
f.city AS order_city,
dg.state,
dg.pincode,
COUNT(*) AS orders,
ROUND(SUM(f.net_amount), 2) AS net_revenue,
ROUND(AVG(f.delivery_minutes), 2) AS avg_delivery_minutes,
CONCAT(ROUND(100.0 * AVG(CASE WHEN f.delivery_success_flag THEN 1 ELSE 0 END), 2), '%') AS delivery_success_pct
FROM workspace.swiggy.swiggy_fact_transactions f
JOIN 
workspace.swiggy.swiggy_dim_geo dg
ON 
f.geo_id = dg.geo_id
GROUP BY f.city, dg.state, dg.pincode
ORDER BY net_revenue DESC;


-- COMMAND ----------

