-- ============================================================
-- O01: FULFILLMENT TIME BREAKDOWN BY RESTAURANT
-- ============================================================

WITH ops_metrics AS (
  SELECT
    restaurant_id,
    city,
    market_tier,
    month,
    month_name,
    ROUND(AVG(
      TIMESTAMP_DIFF(restaurant_accepted_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60), 2)                     AS avg_accept_time_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(driver_assigned_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60), 2)                     AS avg_assign_time_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        restaurant_accepted_datetime_utc, SECOND) / 60), 2)              AS avg_prep_time_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        driver_arrived_at_restaurant_utc, SECOND) / 60), 2)              AS avg_driver_wait_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
        driver_picked_up_datetime_utc, SECOND) / 60), 2)                 AS avg_delivery_time_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60), 2)                     AS avg_total_fulfillment_mins,
    COUNT(order_id)                                                       AS total_orders,
    ROUND(AVG(restaurant_rating), 2)                                      AS avg_restaurant_rating,
    ROUND(AVG(driver_rating), 2)                                          AS avg_driver_rating
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY restaurant_id, city, market_tier, month, month_name
)
SELECT
  *,
  CASE
    WHEN avg_prep_time_mins > 20 THEN 'Slow Kitchen (>20 min)'
    WHEN avg_prep_time_mins BETWEEN 15 AND 20 THEN 'Average (15-20 min)'
    ELSE 'Fast Kitchen (<15 min)'
  END                                                                     AS kitchen_speed_flag
FROM ops_metrics
ORDER BY market_tier, city, month;


-- ============================================================
-- O02: RESTAURANT SCORECARD — RANKED BY OPS PERFORMANCE
-- ============================================================

SELECT
  restaurant_id,
  city,
  market_tier,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60), 2)                AS avg_prep_time_mins,
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      driver_arrived_at_restaurant_utc, SECOND) / 60), 2)                AS avg_driver_wait_mins,
  ROUND(AVG(
    TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
      order_placed_datetime_utc, SECOND) / 60), 2)                       AS avg_total_fulfillment_mins,
  ROUND(AVG(restaurant_rating), 2)                                        AS avg_restaurant_rating,
  ROUND(AVG(driver_rating), 2)                                            AS avg_driver_rating,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  RANK() OVER (ORDER BY AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60) ASC)               AS prep_time_rank
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY restaurant_id, city, market_tier
ORDER BY avg_prep_time_mins ASC;


-- ============================================================
-- O03: CANCELLATION BREAKDOWN — BY REASON, TIER, CITY, MONTH
-- ============================================================

SELECT
  market_tier,
  city,
  month_name,
  cancellation_reason,
  COUNT(order_id)                                                         AS cancelled_orders,
  ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER
    (PARTITION BY market_tier, city, month_name) * 100, 2)               AS pct_of_city_cancellations,
  ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER() * 100, 2)          AS pct_of_all_cancellations
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status != 'completed'
  AND cancellation_reason IS NOT NULL
GROUP BY market_tier, city, month_name, cancellation_reason
ORDER BY market_tier, city, month_name, cancelled_orders DESC;


-- ============================================================
-- O04: DRIVER WAIT TIME — WHICH RESTAURANTS MAKE DRIVERS WAIT?
-- ============================================================

SELECT
  restaurant_id,
  city,
  market_tier,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      driver_arrived_at_restaurant_utc, SECOND) / 60), 2)                AS avg_driver_wait_mins,
  ROUND(MAX(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      driver_arrived_at_restaurant_utc, SECOND) / 60), 2)                AS max_driver_wait_mins,
  ROUND(COUNTIF(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      driver_arrived_at_restaurant_utc, SECOND) / 60 > 10) / COUNT(*) * 100, 2) AS pct_waits_over_10min,
  RANK() OVER (ORDER BY AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      driver_arrived_at_restaurant_utc, SECOND) / 60) DESC)              AS wait_rank_worst_first
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
  AND driver_arrived_at_restaurant_utc IS NOT NULL
GROUP BY restaurant_id, city, market_tier
ORDER BY avg_driver_wait_mins DESC;


-- ============================================================
-- O05: MONTHLY OPS TREND — PREP TIME DETERIORATION OVER TIME
-- ============================================================

SELECT
  restaurant_id,
  city,
  market_tier,
  month,
  month_name,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60), 2)                AS avg_prep_time_mins,
  ROUND(AVG(restaurant_rating), 2)                                        AS avg_rating,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  -- Flag month over month deterioration
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60)
    - LAG(AVG(TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60))
      OVER (PARTITION BY restaurant_id ORDER BY month), 2)               AS prep_time_change_vs_prev_month
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY restaurant_id, city, market_tier, month, month_name
ORDER BY restaurant_id, month;
