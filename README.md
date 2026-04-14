# Chipotle x DoorDash — SQL Analysis

**Project:** Q4 2024 Partnership QBR Analysis  
**Dataset:** Synthetic Chipotle orders data 68,265 orders across 23 locations, 8 cities, Sept - Nov 2024  
**Stack:** Google BigQuery + Looker Studio  
**Live Dashboard:** [Link to Looker Studio]

---

## Folder Structure

```
/sql
  /summary        → Master business overview queries
  /growth         → G01–G07: Growth track analysis
  /ops            → O01–O05: Operational efficiency track
  /matrix         → M01–M03: Restaurant classification matrix
```

---

## Query Index

### Summary
| File | Description |
|------|-------------|
| `master_summary.sql` | Overall snapshot, by-tier breakdown, and monthly trend |

### Growth Track
| Query | Description |
|-------|-------------|
| G01 | GMV and orders by tier and city with % of total |
| G02 | Monthly GMV trend by tier with MoM growth rates |
| G03 | New vs returning customers by month and city |
| G04 | Repeat rate and customer LTV by city and tier |
| G05 | DashPass penetration and AOV impact by tier and city |
| G06 | Channel mix (app / web / storefront) - orders, AOV, performance |
| G07 | Location-level growth analysis with growing/stable/declining classification |

### Ops Track
| Query | Description |
|-------|-------------|
| O01 | Fulfillment time breakdown by restaurant and month |
| O02 | Restaurant scorecard ranked by prep time and ops metrics |
| O03 | Cancellation breakdown by reason, tier, city, and month |
| O04 | Driver wait time ranking which - locations make drivers wait most |
| O05 | Monthly prep time trend to identify operational deterioration |

### Classification Matrix
| Query | Description |
|-------|-------------|
| M01 | Restaurant growth scores — GMV volume and Sept–Nov growth rate |
| M02 | Restaurant ops scores — prep time, rating, refund rate, cancellation rate |
| M03 | Final 2×2 matrix: Star / Operational Risk / Hidden Gem / Problem Location |

---

## Key Findings

- **Total GMV:** $2.37M across 3 months, 23 locations, 8 cities
- **Tier 1 dominates:** 55.2% of GMV from 12 locations; Tier 3 contributes only 12.4% from 4 locations
- **AOV is flat everywhere (~$34–35):** Growth must come from frequency and retention, not ticket size
- **Repeat rate declines with tier:** Tier 1 ~55%, Tier 3 ~49%
- **Ops are deteriorating:** Prep times increased Nov vs Sept at 4 underperforming locations
- **SF underperforms despite highest location count:** 5 locations, but best SF location ranks 8th in Tier 1 GMV
- **DashPass penetration drops with tier:** 40% in Tier 1 vs 22% in Tier 3 — significant upside opportunity
