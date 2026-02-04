-- ============================================================
-- SWIGGY MINI PROJECT
-- Databricks SQL | Schema: swiggy.sdf
-- ============================================================


-- ============================================================
-- PART A: WARM-UP (DATA FAMILIARITY)
-- ============================================================

-- A1) Preview the latest 20 transactions ordered by date and time.
--  WRITE YOUR QUERY HERE


-- A2) Find the minimum and maximum transaction_date in the fact table.
--  WRITE YOUR QUERY HERE


-- A3) Show the total number of orders per city in descending order.
--  WRITE YOUR QUERY HERE


-- A4) Calculate the percentage of orders where a coupon was used.
--  WRITE YOUR QUERY HERE


-- A5) Find the average delivery time (delivery_minutes) by city.
--  WRITE YOUR QUERY HERE



-- ============================================================
-- PART B: CORE BUSINESS QUESTIONS
-- ============================================================

-- B1) Calculate monthly net revenue by city.
--     Output columns: city, year_month, net_revenue
--  WRITE YOUR QUERY HERE


-- B2) For each month, calculate:
--     • total gross amount
--     • total coupon discount
--     • percentage of coupon discount over gross amount
--  WRITE YOUR QUERY HERE


-- B3) For each month, calculate:
--     • total discount amount
--     • total membership benefit amount
--     • percentage share of membership benefit in total discount
--  WRITE YOUR QUERY HERE


-- B4) Identify the top 20 customers by net spending in the last 30 days.
--     Output: customer_id, total_net_amount, total_orders
--  WRITE YOUR QUERY HERE


-- B5) Calculate the monthly repeat rate:
--     • Active customers per month
--     • Repeat customers (2+ orders in same month)
--     • Repeat rate percentage
--  WRITE YOUR QUERY HERE


-- B6) Calculate delivery success rate by city and device type.
--  WRITE YOUR QUERY HERE


-- B7) Compare average delivery time for raining vs non-raining orders by city.
--  WRITE YOUR QUERY HERE


-- B8) Identify the worst 50 deliveries based on:
--     • Failed deliveries OR
--     • Very high delivery time
--     Sort with worst cases first.
--  WRITE YOUR QUERY HERE


-- B9) Calculate Campaign CTR (Click-Through Rate) by campaign_id.
--     Consider only exposed orders.
--  WRITE YOUR QUERY HERE


-- B10) Compare average net order value for:
--      • Campaign exposed orders
--      • Non-exposed orders
--      Split by city.
--  WRITE YOUR QUERY HERE



-- ============================================================
-- PART C: DIMENSION-HEAVY ANALYTICS
-- ============================================================

-- C1) Create an enriched order view by joining:
--     fact_transactions with:
--     • dim_customer
--     • dim_geo
--     • dim_restaurant_product
--     • dim_coupon
--     • dim_campaign
--     Include key customer, geo, product, coupon, and campaign attributes.
--  WRITE YOUR QUERY HERE


-- C2) Data Quality Check:
--     Identify orphan fact records (missing dimension matches) for:
--     • Customer
--     • Geo
--     • Restaurant Product
--     • Coupon (only when coupon_used_flag = 1)
--     • Campaign (only when campaign_exposed_flag = 1)
--  WRITE YOUR QUERY HERE


-- C3) Find the top 5 cuisines by net revenue for each city and month.
--     Use cuisine_tag from the restaurant product dimension.
--  WRITE YOUR QUERY HERE


-- C4) Create a restaurant leaderboard:
--     • Top restaurants by net revenue
--     • Split by city
--     • Only include orders from the last 60 days
--  WRITE YOUR QUERY HERE


-- C5) Perform coupon performance analysis:
--     For each coupon:
--     • Number of orders
--     • Total coupon burn
--     • Average gross amount
--     • Average net amount
--  WRITE YOUR QUERY HERE


-- C6) Campaign performance analysis:
--     Enrich with campaign metadata and calculate:
--     • Exposed orders
--     • Clicked orders
--     • CTR
--     • Net revenue from exposed orders
--     • Coupon burn
--     • Revenue per coupon burn
--  WRITE YOUR QUERY HERE


-- C7) Geo drill-down analysis:
--     Using state and pincode from dim_geo, calculate:
--     • Orders
--     • Net revenue
--     • Average delivery time
--     • Delivery success rate
--  WRITE YOUR QUERY HERE