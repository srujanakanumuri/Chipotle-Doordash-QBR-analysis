-- ============================================================
-- M01: RESTAURANT GROWTH SCORE
-- ============================================================

SELECT
  restaurant_id,
  city,
  market_tier,
  SUM(order_total)                                                        AS total_gmv,
  COUNT(order_id)                                                         AS total_orders,
  ROUND(AVG(order_total), 2)                                              AS avg_order_value,
  ROUND(SUM(order_total) / 3, 2)                                          AS avg_monthly_gmv,
  ROUND((SUM(CASE WHEN month = 11 THEN order_total ELSE 0 END) -
    SUM(CASE WHEN month = 9 THEN order_total ELSE 0 END)) /
    NULLIF(SUM(CASE WHEN month = 9 THEN order_total ELSE 0 END), 0)
    * 100, 2)                                                             AS gmv_growth_sep_to_nov
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
WHERE order_status = 'completed'
GROUP BY restaurant_id, city, market_tier
ORDER BY gmv_growth_sep_to_nov DESC;


-- ============================================================
-- M02: RESTAURANT OPS SCORE
-- ============================================================

SELECT
  restaurant_id,
  city,
  market_tier,
  ROUND(AVG(
    TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
      order_placed_datetime_utc, SECOND) / 60), 2)                       AS avg_fulfillment_mins,
  ROUND(AVG(
    TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
      restaurant_accepted_datetime_utc, SECOND) / 60), 2)                AS avg_prep_time_mins,
  ROUND(AVG(restaurant_rating), 2)                                        AS avg_rating,
  ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)                AS refund_rate_pct,
  ROUND(COUNTIF(order_status != 'completed') / COUNT(*) * 100, 2)        AS cancellation_rate_pct
FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
GROUP BY restaurant_id, city, market_tier
ORDER BY avg_prep_time_mins ASC;


-- ============================================================
-- M03: FINAL CLASSIFICATION MATRIX — 2x2 GROWTH VS OPS
-- ============================================================

WITH growth_scores AS (
  SELECT
    restaurant_id,
    city,
    market_tier,
    SUM(order_total)                                                      AS total_gmv,
    COUNT(order_id)                                                       AS total_orders,
    ROUND(AVG(order_total), 2)                                            AS avg_order_value,
    ROUND(SUM(order_total) / 3, 2)                                        AS avg_monthly_gmv,
    ROUND((SUM(CASE WHEN month = 11 THEN order_total ELSE 0 END) -
      SUM(CASE WHEN month = 9 THEN order_total ELSE 0 END)) /
      NULLIF(SUM(CASE WHEN month = 9 THEN order_total ELSE 0 END), 0)
      * 100, 2)                                                           AS gmv_growth_sep_to_nov
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  WHERE order_status = 'completed'
  GROUP BY restaurant_id, city, market_tier
),
ops_scores AS (
  SELECT
    restaurant_id,
    ROUND(AVG(
      TIMESTAMP_DIFF(delivered_to_customer_datetime_utc,
        order_placed_datetime_utc, SECOND) / 60), 2)                     AS avg_fulfillment_mins,
    ROUND(AVG(
      TIMESTAMP_DIFF(driver_picked_up_datetime_utc,
        restaurant_accepted_datetime_utc, SECOND) / 60), 2)              AS avg_prep_time_mins,
    ROUND(AVG(restaurant_rating), 2)                                      AS avg_rating,
    ROUND(SUM(refunded_amount) / SUM(order_total) * 100, 2)              AS refund_rate_pct,
    ROUND(COUNTIF(order_status != 'completed') / COUNT(*) * 100, 2)      AS cancellation_rate_pct
  FROM `focal-shape-493019-j9.Chipotle_Orders.Chipotle_Orders`
  GROUP BY restaurant_id
),
-- Normalize scores 0-100 using PERCENT_RANK
growth_ranked AS (
  SELECT
    restaurant_id,
    city,
    market_tier,
    total_gmv,
    avg_monthly_gmv,
    gmv_growth_sep_to_nov,
    avg_order_value,
    total_orders,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_gmv) * 50 +
      PERCENT_RANK() OVER (ORDER BY gmv_growth_sep_to_nov) * 50, 1)      AS growth_score
  FROM growth_scores
),
ops_ranked AS (
  SELECT
    restaurant_id,
    avg_fulfillment_mins,
    avg_prep_time_mins,
    avg_rating,
    refund_rate_pct,
    cancellation_rate_pct,
    -- Ops score: high rating good, low times good, low refund/cancel good
    ROUND(PERCENT_RANK() OVER (ORDER BY avg_rating) * 40 +
      PERCENT_RANK() OVER (ORDER BY avg_prep_time_mins DESC) * 30 +
      PERCENT_RANK() OVER (ORDER BY refund_rate_pct DESC) * 15 +
      PERCENT_RANK() OVER (ORDER BY cancellation_rate_pct DESC) * 15, 1) AS ops_score
  FROM ops_scores
),
combined AS (
  SELECT
    g.restaurant_id,
    g.city,
    g.market_tier,
    g.total_orders,
    g.avg_monthly_gmv,
    g.gmv_growth_sep_to_nov,
    o.avg_fulfillment_mins,
    o.avg_prep_time_mins,
    o.avg_rating,
    o.refund_rate_pct,
    o.cancellation_rate_pct,
    g.growth_score,
    o.ops_score
  FROM growth_ranked g
  JOIN ops_ranked o ON g.restaurant_id = o.restaurant_id
)
SELECT
  restaurant_id,
  city,
  market_tier,
  total_orders,
  avg_monthly_gmv,
  gmv_growth_sep_to_nov,
  avg_fulfillment_mins,
  avg_prep_time_mins,
  avg_rating,
  refund_rate_pct,
  cancellation_rate_pct,
  growth_score,
  ops_score,
  -- Quadrant classification
  CASE
    WHEN growth_score >= 50 AND ops_score >= 50 THEN 'Star'
    WHEN growth_score >= 50 AND ops_score < 50  THEN 'Operational Risk'
    WHEN growth_score < 50  AND ops_score >= 50 THEN 'Hidden Gem'
    ELSE 'Problem Location'
  END                                                                     AS classification,
  -- Recommended action
  CASE
    WHEN growth_score >= 50 AND ops_score >= 50
      THEN 'Protect and scale — use as internal benchmark'
    WHEN growth_score >= 50 AND ops_score < 50
      THEN 'Urgent ops intervention — volume masking problems'
    WHEN growth_score < 50  AND ops_score >= 50
      THEN 'Growth investment — solid ops, needs demand drivers'
    ELSE 'Immediate review — underperforming on both dimensions'
  END                                                                     AS recommended_action
FROM combined
ORDER BY classification, growth_score DESC;
