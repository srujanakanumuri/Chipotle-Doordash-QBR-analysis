# Chipotle x DoorDash Partnership QBR Analysis
### Q4 2024 | September - November 2024 | 23 Locations | 8 Cities

---

## Overview

This project simulates a Quarterly Business Review (QBR) analysis for the Chipotle x DoorDash delivery partnership. The goal was to build a complete end-to-end analytical workflow from synthetic dataset creation through SQL analysis in BigQuery to an interactive Looker Studio dashboard and written findings report. The dataset was created synthetically to reflect realistic delivery marketplace dynamics. 

The analysis follows the structure of a real QBR: start with a business snapshot, understand where growth is strong and where it is weak, identify operational problems and their root causes, and synthesize everything into prioritized recommendations.

---

## Dataset

The synthetic dataset contains 68,265 orders across 23 Chipotle locations in 8 cities, spanning September through November 2024, generated using Python.

**Cities and market tiers:**
- Tier 1 (established markets): San Francisco, Chicago, Brooklyn
- Tier 2 (growth markets): Dallas, Nashville, Philadelphia
- Tier 3 (emerging markets): Denver, Minneapolis

**Dataset structure:** 28 columns per order including full timestamp chain (order placed → restaurant accepted → driver assigned → driver arrived → driver picked up → delivered), customer ID, restaurant ID, city, market tier, order status, cancellation reason, DashPass flag, promotion type, order channel (app / web / storefront), number of items, financials (order total, discount amount, refund amount), and ratings (restaurant rating, driver rating).

---

## Tools

| Tool | Purpose |
|---|---|
| Python | Synthetic dataset generation |
| Google BigQuery | SQL analysis — 19 saved analysis tables |
| Looker Studio | Interactive 4-page dashboard |

---

## Repository Structure

```
/data
  chipotle_orders.csv              — 68,265 order records
  chipotle_restaurants.csv         — 23 restaurant reference rows
  generate_dataset.py              — Python generation script

/docs
  01_context_and_prompt.md         — Project brief, context, analytical approach
  02_data_dictionary.md            — Schema, metric definitions, glossary
  03_insights_report.md            — Full written findings and recommendations

/sql
  /summary
    master_summary.sql
    master_summary_tier.sql
    master_summary_month.sql
  /growth
    g01_gmv_by_city.sql
    g03_new_vs_returning.sql
    g04_repeat_rate_ltv.sql
    g05_dashpass_penetration.sql
    g06_channel_mix.sql
    g07_discount_by_city.sql
    location_level_growth.sql
    city_acquisition_retention.sql
    city_growth_rates.sql
  /ops
    ops03_cancellation_analysis.sql
    ops04_driver_wait_time.sql
    ops05_prep_time_trend.sql
    restaurant_scorecard.sql
    fulfillment_by_restaurant.sql
    supply_side_efficiency.sql
    comprehensive_ops.sql
    city_cancellation_summary.sql
  /matrix
    classification_matrix_growth_vs_ops.sql

/dashboard
  dashboard_link.md                — Looker Studio link and page descriptions
```

---

## Key Findings

**Growth — demand side**

The business seems to have a demand problem, not a supply problem. DoorDash's fulfillment infrastructure is working meaning drivers are being assigned, orders are being picked up, and delivery times are consistent across every market. The constraint on growth is customer-side.

- $2.37M GMV across 23 locations in Q4 2024 stable but flat, with no meaningful month-over-month growth
- AOV is identical at $34–35 everywhere no market, tier, or channel shows price differentiation. Growth requires more customers or more frequent ordering, not higher ticket sizes
- Brooklyn and Philadelphia generate the highest revenue per location ($39K/month), outperforming San Francisco ($32.4K)
- New customer acquisition declined 53% in Denver between September and November which doesnt seem to be a marketing problem. High cancellation and refund rates in Tier 3 are likely creating poor first-order experiences that prevent reordering
- DashPass penetration ranges from 43% in SF to 21% in Denver. Higher penetration correlates with better per-order economics and more frequent ordering closing this gap in lower-tier markets is the most actionable near-term growth lever

**Operations — supply side**

The supply side breaks into two distinct problems with different causes, different owners, and different fixes.

- Four locations have a kitchen throughput crisis: CHIP_1003 (SF), CHIP_1007 (Chicago), CHIP_1011 (Brooklyn), CHIP_1015 (Nashville). Prep times have doubled the healthy benchmark and are worsening by ~3 minutes every month. The problem seems to come entirely kitchen-side as delivery times, driver ratings, and acceptance times are identical across all 23 locations
- Tier 3 markets (Denver, Minneapolis) have a separate reliability problem and not a prep time problem. Cancellation rates of 7–8% vs 2–3% in Tier 1 are driven by restaurants going unexpectedly offline during active order windows. This is an uptime issue requiring a different investigation and a different fix from the kitchen throughput problem

**Classification Matrix**
- 3 Star locations: high GMV + strong ops
- 4 Hidden Gem locations: strong ops, growth opportunity
- 4 Operational Risk locations: high volume masking kitchen problems
- 4 Problem locations: underperforming on both dimensions

---

## Live Dashboard

[Looker Studio — Chipotle x DoorDash Partnership QBR](https://datastudio.google.com/reporting/e1ba4d3b-246c-4846-b99e-7acd0eec752a)

---

## Methodology Note

All data is synthetic. The analytical framework mirrors how a strategy or partnerships team at a delivery marketplace would approach a quarterly business review. See `/docs/01_context_and_prompt.md` for full project context and `/docs/02_data_dictionary.md` for schema and metric definitions.
