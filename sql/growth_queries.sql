-- ============================================================
-- G01: GMV AND ORDERS BY TIER AND CITY
-- ============================================================

SELECT
  market_tier,
  city,
  COUNT(DISTINCT restaurant_id)                                           AS total_locations,
  COUNT(DISTINCT customer_id)                                             AS total_customers,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(SUM(order_total), 2)                                              AS total_gmv,
  ROUND(SUM(order_total) / SUM(SUM(order_total)) OVER() * 100, 2)        AS pct_of_total_gmv,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(COUNT(order_id) / COUNT(DISTINCT restaurant_id) / 3, 0)          AS avg_orders_per_location_per_month,
  ROUND(SUM(order_total) / COUNT(DISTINCT restaurant_id) / 3, 2)         AS avg_gmv_per_location_per_month
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY market_tier, city
ORDER BY market_tier, total_gmv DESC;


-- ============================================================
-- G02: MONTHLY TREND BY TIER — GROWTH RATES MOM
-- ============================================================

WITH monthly_by_tier AS (
  SELECT
    market_tier,
    month,
    month_name,
    COUNT(order_id)                                                       AS monthly_orders,
    ROUND(SUM(order_total), 2)                                            AS monthly_gmv,
    ROUND(AVG(order_total), 2)                                            AS monthly_aov,
    COUNT(DISTINCT customer_id)                                           AS monthly_customers,
    ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)               AS dashpass_pct,
    ROUND(AVG(
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        restaurant_accepted_datetime_utc, SECOND) / 60), 2)              AS avg_prep_time_mins,
    ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)              AS refund_rate_pct
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY market_tier, month, month_name
)
SELECT
  *,
  ROUND((monthly_gmv - LAG(monthly_gmv) OVER (PARTITION BY market_tier ORDER BY month))
    / LAG(monthly_gmv) OVER (PARTITION BY market_tier ORDER BY month) * 100, 2) AS gmv_growth_pct_mom,
  ROUND((monthly_orders - LAG(monthly_orders) OVER (PARTITION BY market_tier ORDER BY month))
    / LAG(monthly_orders) OVER (PARTITION BY market_tier ORDER BY month) * 100, 2) AS order_growth_pct_mom
FROM monthly_by_tier
ORDER BY market_tier, month;


-- ============================================================
-- G03: NEW VS RETURNING CUSTOMERS BY MONTH AND CITY
-- ============================================================

WITH first_order AS (
  SELECT
    customer_id,
    MIN(month) AS first_order_month
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY customer_id
),
orders_with_type AS (
  SELECT
    o.city,
    o.month,
    o.month_name,
    o.customer_id,
    CASE WHEN o.month = f.first_order_month THEN 'new' ELSE 'returning' END AS customer_type
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders` o
  JOIN first_order f ON o.customer_id = f.customer_id
  WHERE o.order_status = 'completed'
)
SELECT
  city,
  month,
  month_name,
  COUNTIF(customer_type = 'new')                                         AS new_customers,
  COUNTIF(customer_type = 'returning')                                   AS returning_customers,
  COUNT(*)                                                                AS total_orders,
  ROUND(COUNTIF(customer_type = 'returning') / COUNT(*) * 100, 2)       AS returning_pct
FROM orders_with_type
GROUP BY city, month, month_name
ORDER BY city, month;


-- ============================================================
-- G04: REPEAT RATE AND CUSTOMER LTV BY CITY AND TIER
-- ============================================================

WITH customer_stats AS (
  SELECT
    customer_id,
    city,
    market_tier,
    COUNT(order_id)                                                       AS total_orders,
    ROUND(SUM(order_total), 2)                                            AS total_spend,
    MIN(DATE(order_placed_datetime_utc))                                  AS first_order_date,
    MAX(DATE(order_placed_datetime_utc))                                  AS last_order_date,
    DATE_DIFF(MAX(DATE(order_placed_datetime_utc)),
      MIN(DATE(order_placed_datetime_utc)), DAY)                         AS days_between_first_last
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY customer_id, city, market_tier
)
SELECT
  city,
  market_tier,
  COUNT(customer_id)                                                      AS total_customers,
  COUNTIF(total_orders > 1)                                               AS repeat_customers,
  ROUND(COUNTIF(total_orders > 1) / COUNT(customer_id) * 100, 2)         AS repeat_rate_pct,
  ROUND(AVG(total_orders), 2)                                             AS avg_orders_per_customer,
  ROUND(AVG(CASE WHEN total_orders = 1 THEN total_spend END), 2)          AS single_order_ltv,
  ROUND(AVG(CASE WHEN total_orders > 1 THEN total_spend END), 2)          AS repeat_customer_ltv,
  ROUND(AVG(CASE WHEN total_orders > 1 THEN days_between_first_last END), 0) AS avg_days_between_orders
FROM customer_stats
GROUP BY city, market_tier
ORDER BY repeat_rate_pct DESC;


-- ============================================================
-- G05: DASHPASS PENETRATION AND AOV IMPACT BY TIER AND CITY
-- ============================================================

SELECT
  market_tier,
  city,
  COUNT(order_id)                                                         AS total_orders,
  COUNTIF(is_dashpass = TRUE)                                             AS dashpass_orders,
  ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)                 AS dashpass_penetration_pct,
  ROUND(AVG(CASE WHEN is_dashpass = TRUE THEN order_total END), 2)        AS dashpass_avg_order_value,
  ROUND(AVG(CASE WHEN is_dashpass = FALSE THEN order_total END), 2)       AS non_dashpass_avg_order_value,
  ROUND(AVG(CASE WHEN is_dashpass = TRUE THEN order_total END)
    - AVG(CASE WHEN is_dashpass = FALSE THEN order_total END), 2)         AS dashpass_aov_premium,
  ROUND(SUM(CASE WHEN is_dashpass = TRUE THEN order_total ELSE 0 END), 2) AS dashpass_gmv,
  ROUND(SUM(CASE WHEN is_dashpass = FALSE THEN order_total ELSE 0 END), 2) AS non_dashpass_gmv
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY market_tier, city
ORDER BY market_tier, dashpass_penetration_pct DESC;


-- ============================================================
-- G06: CHANNEL MIX — ORDERS, AOV, AND PERFORMANCE BY CHANNEL
-- ============================================================

SELECT
  order_channel,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER() * 100, 2)          AS pct_of_orders,
  ROUND(SUM(order_total), 2)                                              AS total_gmv,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(SUM(discount_amount) / SUM(order_total) * 100, 2)                AS discount_rate_pct,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)                 AS dashpass_pct,
  COUNT(DISTINCT customer_id)                                             AS unique_customers
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY order_channel
ORDER BY total_orders DESC;


-- ============================================================
-- G07: LOCATION LEVEL GROWTH ANALYSIS (per restaurant)
-- ============================================================

WITH location_monthly AS (
  SELECT
    restaurant_id,
    city,
    market_tier,
    month,
    month_name,
    COUNT(order_id)                                                       AS monthly_orders,
    ROUND(SUM(order_total), 2)                                            AS monthly_gmv,
    ROUND(AVG(order_total), 2)                                            AS monthly_aov,
    COUNT(DISTINCT customer_id)                                           AS monthly_customers
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY restaurant_id, city, market_tier, month, month_name
),
location_growth AS (
  SELECT
    *,
    LAG(monthly_gmv) OVER (PARTITION BY restaurant_id ORDER BY month)    AS prev_month_gmv,
    LAG(monthly_orders) OVER (PARTITION BY restaurant_id ORDER BY month) AS prev_month_orders,
    ROUND((monthly_gmv - LAG(monthly_gmv) OVER (PARTITION BY restaurant_id ORDER BY month))
      / LAG(monthly_gmv) OVER (PARTITION BY restaurant_id ORDER BY month) * 100, 2) AS gmv_growth_pct,
    ROUND((monthly_orders - LAG(monthly_orders) OVER (PARTITION BY restaurant_id ORDER BY month))
      / LAG(monthly_orders) OVER (PARTITION BY restaurant_id ORDER BY month) * 100, 2) AS order_growth_pct
  FROM location_monthly
),
location_summary AS (
  SELECT
    restaurant_id,
    city,
    market_tier,
    SUM(monthly_orders)                                                   AS total_orders_3mo,
    ROUND(SUM(monthly_gmv), 2)                                            AS total_gmv_3mo,
    ROUND(AVG(monthly_gmv), 2)                                            AS avg_monthly_gmv,
    ROUND(AVG(monthly_orders), 0)                                         AS avg_monthly_orders,
    ROUND(AVG(monthly_aov), 2)                                            AS avg_order_value,
    ROUND(AVG(CASE WHEN month = 10 THEN gmv_growth_pct END), 2)          AS sep_to_oct_gmv_growth,
    ROUND(AVG(CASE WHEN month = 11 THEN gmv_growth_pct END), 2)          AS oct_to_nov_gmv_growth,
    ROUND(AVG(CASE WHEN month IN (10,11) THEN gmv_growth_pct END), 2)    AS avg_gmv_growth_pct,
    ROUND(SUM(monthly_customers), 0)                                      AS total_customers_3mo
  FROM location_growth
  GROUP BY restaurant_id, city, market_tier
)
SELECT
  restaurant_id,
  city,
  market_tier,
  total_orders_3mo,
  total_gmv_3mo,
  avg_monthly_gmv,
  avg_monthly_orders,
  avg_order_value,
  sep_to_oct_gmv_growth,
  oct_to_nov_gmv_growth,
  avg_gmv_growth_pct,
  total_customers_3mo,
  CASE
    WHEN avg_gmv_growth_pct > 2 THEN 'Growing'
    WHEN avg_gmv_growth_pct BETWEEN -2 AND 2 THEN 'Stable'
    ELSE 'Declining'
  END                                                                     AS growth_classification,
  RANK() OVER (PARTITION BY city ORDER BY total_gmv_3mo DESC)            AS rank_in_city,
  RANK() OVER (PARTITION BY market_tier ORDER BY total_gmv_3mo DESC)     AS rank_in_tier
FROM location_summary
ORDER BY market_tier, city, total_gmv_3mo DESC;
