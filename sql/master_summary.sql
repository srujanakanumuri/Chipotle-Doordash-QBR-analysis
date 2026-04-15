-- ============================================================
-- MASTER SUMMARY
-- Overall business snapshot across all 3 months
-- ============================================================

SELECT
  -- Volume
  COUNT(order_id)                                                         AS total_orders,
  COUNTIF(order_status = 'completed')                                     AS completed_orders,
  COUNTIF(order_status != 'completed')                                    AS cancelled_orders,

  -- Time range
  MIN(DATE(order_placed_datetime_utc))                                    AS period_start,
  MAX(DATE(order_placed_datetime_utc))                                    AS period_end,

  -- Locations and people
  COUNT(DISTINCT restaurant_id)                                           AS total_locations,
  COUNT(DISTINCT customer_id)                                             AS total_customers,
  COUNT(DISTINCT driver_id)                                               AS total_drivers,

  -- Revenue
  ROUND(SUM(order_total), 2)                                              AS total_gmv,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(SUM(discount_amount), 2)                                          AS total_discounts,
  ROUND(SUM(discount_amount) / SUM(order_total) * 100, 2)                AS discount_rate_pct,
  ROUND(SUM(refunded_amount), 2)                                          AS total_refunds,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,

  -- DashPass
  ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)                 AS dashpass_order_pct,

  -- Fulfillment times (completed orders only, in minutes)
  ROUND(AVG(
    CASE WHEN order_status = 'completed' THEN
      TIMESTAMP_DIFF(restaurant_accepted_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60 END), 2)                 AS avg_accept_time_mins,
  ROUND(AVG(
    CASE WHEN order_status = 'completed' THEN
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        restaurant_accepted_datetime_utc, SECOND) / 60 END), 2)          AS avg_prep_time_mins,
  ROUND(AVG(
    CASE WHEN order_status = 'completed' THEN
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        driver_arrived_at_restaurant_utc, SECOND) / 60 END), 2)          AS avg_driver_wait_mins,
  ROUND(AVG(
    CASE WHEN order_status = 'completed' THEN
      TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
        driver_picked_up_datetime_utc, SECOND) / 60 END), 2)             AS avg_delivery_time_mins,
  ROUND(AVG(
    CASE WHEN order_status = 'completed' THEN
      TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60 END), 2)                 AS avg_total_fulfillment_mins,

  -- Cancellation breakdown
  ROUND(COUNTIF(cancellation_reason = 'restaurant_cancelled') / COUNT(*) * 100, 2) AS restaurant_cancel_pct,
  ROUND(COUNTIF(cancellation_reason = 'customer_cancelled') / COUNT(*) * 100, 2)   AS customer_cancel_pct,

  -- Channel mix
  ROUND(COUNTIF(order_channel = 'storefront') / COUNT(*) * 100, 2)      AS storefront_pct,
  ROUND(COUNTIF(order_channel = 'app') / COUNT(*) * 100, 2)             AS app_pct,
  ROUND(COUNTIF(order_channel = 'web') / COUNT(*) * 100, 2)             AS web_pct

FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`;


-- ============================================================
-- MASTER SUMMARY BY TIER
-- Same metrics broken out by Tier 1 / 2 / 3
-- ============================================================

SELECT
  market_tier,
  COUNT(order_id)                                                         AS total_orders,
  COUNTIF(order_status = 'completed')                                     AS completed_orders,
  COUNT(DISTINCT restaurant_id)                                           AS total_locations,
  COUNT(DISTINCT customer_id)                                             AS total_customers,
  ROUND(SUM(order_total), 2)                                              AS total_gmv,
  ROUND(SUM(order_total) / SUM(SUM(order_total)) OVER() * 100, 2)        AS pct_of_total_gmv,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(SUM(discount_amount) / SUM(order_total) * 100, 2)                AS discount_rate_pct,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)                 AS dashpass_pct,
  ROUND(AVG(CASE WHEN order_status = 'completed' THEN
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60 END), 2)            AS avg_prep_time_mins,
  ROUND(AVG(CASE WHEN order_status = 'completed' THEN
    TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
      order_placed_datetime_utc, SECOND) / 60 END), 2)                   AS avg_total_fulfillment_mins,
  ROUND(COUNTIF(order_status != 'completed') / COUNT(*) * 100, 2)        AS cancellation_rate_pct,
  ROUND(COUNTIF(order_channel = 'storefront') / COUNT(*) * 100, 2)       AS storefront_pct
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
GROUP BY market_tier
ORDER BY market_tier;


-- ============================================================
-- MASTER SUMMARY BY MONTH
-- Monthly trend — Sept / Oct / Nov
-- ============================================================

SELECT
  month,
  month_name,
  COUNT(order_id)                                                         AS total_orders,
  COUNTIF(order_status = 'completed')                                     AS completed_orders,
  COUNT(DISTINCT customer_id)                                             AS total_customers,
  ROUND(SUM(order_total), 2)                                              AS total_gmv,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(SUM(discount_amount) / SUM(order_total) * 100, 2)                AS discount_rate_pct,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  ROUND(COUNTIF(is_dashpass = TRUE) / COUNT(*) * 100, 2)                 AS dashpass_pct,
  ROUND(AVG(CASE WHEN order_status = 'completed' THEN
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60 END), 2)            AS avg_prep_time_mins,
  ROUND(AVG(CASE WHEN order_status = 'completed' THEN
    TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
      order_placed_datetime_utc, SECOND) / 60 END), 2)                   AS avg_total_fulfillment_mins,
  ROUND(COUNTIF(order_status != 'completed') / COUNT(*) * 100, 2)        AS cancellation_rate_pct
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
GROUP BY month, month_name
ORDER BY month;
