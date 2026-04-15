# Data Dictionary

---

## Raw Dataset Schema

### chipotle_orders.csv
68,265 rows. One row per order.

| Column | Type | Notes |
|---|---|---|
| `order_id` | STRING | Unique order identifier |
| `customer_id` | STRING | Unique customer identifier. Repeats across orders for returning customers |
| `restaurant_id` | STRING | Links to chipotle_restaurants.csv. Format: CHIP_XXXX |
| `city` | STRING | One of 8 cities across 3 market tiers |
| `market_tier` | STRING | Tier 1 / Tier 2 / Tier 3 — see tier definitions below |
| `order_placed_datetime_utc` | TIMESTAMP | Start of the fulfillment chain |
| `restaurant_accepted_datetime_utc` | TIMESTAMP | Restaurant confirms the order |
| `driver_assigned_datetime_utc` | TIMESTAMP | DoorDash assigns a Dasher |
| `driver_arrived_at_restaurant_utc` | TIMESTAMP | Dasher arrives at restaurant |
| `driver_picked_up_datetime_utc` | TIMESTAMP | Dasher picks up completed order |
| `delivered_to_customer_datetime_utc` | TIMESTAMP | Order delivered. End of fulfillment chain |
| `order_status` | STRING | completed / cancelled_customer_cancelled / cancelled_restaurant_cancelled / cancelled_dasher_cancelled / cancelled_restaurant_closed / cancelled_item_unavailable |
| `is_dashpass` | BOOLEAN | Whether the customer is a DashPass subscriber. Always FALSE for storefront orders |
| `order_channel` | STRING | app / web / storefront |
| `promotion_type` | STRING | none / percentage_discount / free_delivery / free_item. Always none for storefront orders |
| `number_of_items` | INTEGER | Items in the order |
| `order_subtotal` | FLOAT | Pre-discount order value |
| `discount_amount` | FLOAT | Discount applied. 0 for storefront and non-promotional orders |
| `order_total` | FLOAT | Final order value after discount |
| `delivery_fee` | FLOAT | Fee charged to customer. 0 for DashPass orders and some promotions |
| `refunded_amount` | FLOAT | Post-delivery refund. 0 if no refund issued |
| `restaurant_rating` | FLOAT | Customer rating of restaurant, 1–5. NULL for cancelled orders |
| `driver_rating` | FLOAT | Customer rating of Dasher, 1–5. NULL for cancelled orders |
| `month` | INTEGER | 9, 10, or 11 |
| `month_name` | STRING | September, October, or November |

### chipotle_restaurants.csv
23 rows. One row per restaurant location.

| Column | Type | Notes |
|---|---|---|
| `restaurant_id` | STRING | Matches restaurant_id in chipotle_orders.csv |
| `city` | STRING | City of the location |
| `market_tier` | STRING | Tier classification for the city |
| `address` | STRING | Synthetic street address |
| `opened_year` | INTEGER | Synthetic opening year |

---

## Market Tiers

| Tier | Cities | Locations | Characteristics |
|---|---|---|---|
| Tier 1 | San Francisco, Chicago, Brooklyn | 3–5 per city | Established markets. Highest DashPass penetration (~40%). Performance benchmark |
| Tier 2 | Dallas, Nashville, Philadelphia | 2–3 per city | Growth markets. Mid-range volume |
| Tier 3 | Denver, Minneapolis | 2 per city | Emerging markets. Lowest volume, lowest DashPass penetration (~22%), highest cancellation rates |

---

## Derived Metrics

Metrics calculated in SQL from the raw dataset. Included here for reproducibility.

| Metric | Formula |
|---|---|
| `avg_total_fulfillment_mins` | (delivered − order_placed) in seconds / 60 |
| `avg_accept_time_mins` | (restaurant_accepted − order_placed) in seconds / 60 |
| `avg_prep_time_mins` | (driver_picked_up − restaurant_accepted) in seconds / 60 |
| `avg_driver_wait_mins` | (driver_picked_up − driver_arrived_at_restaurant) in seconds / 60 |
| `avg_delivery_time_mins` | (delivered − driver_picked_up) in seconds / 60 |
| `cancellation_rate_pct` | orders where status ≠ completed / total orders × 100 |
| `refund_rate_pct` | orders where refunded_amount > 0 / completed orders × 100 |
| `dashpass_penetration_pct` | orders where is_dashpass = TRUE / total orders × 100 |
| `discount_rate_pct` | SUM(discount_amount) / SUM(order_total) × 100 |
| `avg_gmv_per_location_per_month` | SUM(order_total) / distinct locations / 3 months |
| `repeat_rate_pct` | customers with 2+ orders / all customers × 100 |
| `new_customers` | customers whose first order in the dataset falls in that month |
| `returning_customers` | customers who placed at least one order in a prior month |

---

## Classification Matrix Scoring

Each of the 23 locations is scored on two dimensions and assigned to a quadrant.

**Growth score (0–100)**
Percentile rank of avg monthly GMV (weighted 50%) + percentile rank of GMV growth rate Sept to Nov (weighted 50%)

**Ops score (0–100)**
Percentile rank of avg rating (40%) + inverse percentile rank of avg prep time (30%) + inverse percentile rank of refund rate (20%) + inverse percentile rank of cancellation rate (10%)

Higher is better on both dimensions. Scores are relative — a restaurant is ranked against its peers in the portfolio, not against an external standard.

**Quadrant classification**

| Classification | Criteria | Recommended action |
|---|---|---|
| Star | Growth ≥ 50, Ops ≥ 50 | Protect and scale. Use as internal benchmark |
| Hidden Gem | Growth < 50, Ops ≥ 50 | Strong ops, low volume. Invest in demand generation |
| Operational Risk | Growth ≥ 50, Ops < 50 | High volume masking kitchen problems. Urgent intervention |
| Problem Location | Growth < 50, Ops < 50 | Underperforming on both dimensions. Immediate review |

---

## Key Terms

| Term | Definition |
|---|---|
| **GMV** | Gross Merchandise Value. Total value of completed orders (SUM of order_total) |
| **AOV** | Average Order Value. GMV / number of completed orders |
| **DashPass** | DoorDash's subscription program. Members pay a monthly fee for reduced delivery fees. DashPass customers typically order more frequently and spend slightly more per order |
| **Storefront** | Orders placed through Chipotle's own ordering interface, fulfilled by DoorDash. No DashPass flag, no promotional discounts, no delivery fee discount |
| **Prep time** | Time from restaurant accepting an order to Dasher pickup. Entirely within the restaurant's control — the primary kitchen performance metric in this analysis |
| **Driver wait time** | Time between Dasher arriving at the restaurant and picking up the order. Elevated driver wait is a downstream signal of slow kitchen prep, not a Dasher performance issue |
| **Fulfillment time** | Total time from order placed to delivered. Decomposed as: accept time + prep time + driver wait + delivery time |
| **Search ranking suppression** | When DoorDash's algorithm reduces a restaurant's visibility in search results due to sustained poor fulfillment metrics — typically triggered at fulfillment times above 45–50 minutes |
| **QBR** | Quarterly Business Review. A structured performance review between DoorDash and a restaurant partner covering the prior quarter's results and forward-looking recommendations |
