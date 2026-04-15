# Chipotle x DoorDash Partnership — Q4 2024 Business Review
**Period:** September – November 2024 | **Markets:** 8 cities, 23 locations | **Total GMV:** $2.37M

---

## Executive Summary

The Chipotle x DoorDash partnership generated $2.37M in GMV across 23 locations between September and November 2024, processing 68,265 orders for 33,621 unique customers. The business is stable — but not growing. Monthly GMV peaked in October ($821K) and declined slightly in November ($783K), and average order value is flat at $34–35 across every market and channel. That means the only path to meaningful growth is more customers and more frequent ordering — not higher ticket sizes.

Two problems sit underneath the surface stability. The first is operational: four specific restaurant locations are experiencing a systematic kitchen crisis that is getting measurably worse every month. The second is structural: Tier 3 markets (Denver and Minneapolis) are showing early signs of a declining customer base, and DashPass penetration in these markets is less than half of what it is in Tier 1. Both problems are addressable, but they require different interventions and different owners.

---

## Section 1: Growth Analysis — Demand Side

### Market context

Markets are grouped into three tiers based on city size and assumed delivery market maturity. Tier 1 (San Francisco, Chicago, Brooklyn) are large established markets with 3–5 locations each and the highest DashPass penetration. Tier 2 (Dallas, Nashville, Philadelphia) are mid-size growth markets with 2–3 locations. Tier 3 (Denver, Minneapolis) are emerging markets with 2 locations each and the lowest order volumes. This classification provides a benchmarking framework but should not be treated as a rigid predictor of performance — as the findings below show, tier does not always determine per-location productivity.

### Revenue productivity varies significantly across markets

Brooklyn and Philadelphia generate the highest revenue per location at $39.3K and $39K per location per month respectively — outperforming San Francisco ($32.4K) despite SF having the most locations (5) of any city in the portfolio. Chicago ($35.2K) and Nashville ($37.8K) also outperform SF on a per-location basis.

SF is the largest footprint in the portfolio and has the highest DashPass penetration (43%), yet it produces the least revenue per location of any Tier 1 city. Discounting does not explain the gap — Brooklyn and Philadelphia's discount rates (5.2% and 4.8%) are lower than SF's (5.6%). Part of the underperformance is traceable within this dataset: CHIP_1003, one of SF's five locations, is classified as declining in the location-level growth analysis and is also one of the four kitchen underperformers identified in the ops section. A single underperforming location in a five-location city pulls the per-location average down materially. Whether additional structural factors — delivery zone overlap between SF locations, for example — are also contributing would require further investigation.

Denver is the weakest market at $21.3K per location per month, followed by Minneapolis at $23.8K.

### Growth is driven by acquisition and frequency, not ticket size

Average order value is $34–35 across every city, every tier, and every channel. There is no price differentiation in the market. This is the most important structural finding in the growth analysis: there is no lever to pull on the revenue-per-order side. The only way to grow GMV is to acquire more customers or increase how often existing customers order.

DashPass customers spend approximately $3–4 more per order than non-DashPass customers, and this holds consistently across all eight cities. The gap is modest but reliable. It likely reflects slightly higher price tolerance among subscription customers rather than larger basket sizes — item counts are nearly identical between DashPass and non-DashPass orders (2.75 vs 2.69 items on average).

### New customer acquisition is declining in Tier 3

New customer acquisition fell 53% in Denver between September and November — from roughly 430 new customers in September to approximately 200 in November. Minneapolis shows a similar pattern. This is not a slow drift. It is a sharp decline happening over three months.

Tier 1 and Tier 2 markets held their acquisition levels flat across the same period. The decline is specific to Tier 3.

The likely cause is a compounding problem: Denver and Minneapolis have the highest cancellation rates (8.5% and 6.7%) and the highest refund rates in the portfolio. When new customers experience cancelled or refunded orders in their first interaction with a brand on a platform, they are significantly less likely to reorder. The customer acquisition problem in Tier 3 may not be a marketing problem — it may be an operations problem. This connection is explored further in the ops section.

### DashPass penetration is the clearest growth lever

DashPass penetration ranges from 43% in SF to 21% in Denver — a 22-point gap. Given that DashPass customers spend more per order and order more frequently across DoorDash's platform, closing this gap in Tier 2 and Tier 3 markets is the most actionable growth opportunity identified in this analysis. The cities with the most headroom are Denver (21%), Minneapolis (23%), and Nashville (29%). SF and Chicago are already well-penetrated at 40%+ and are not the priority.

Storefront is a related opportunity. Orders placed through Chipotle's direct ordering channel carry zero discount drag, have the highest AOV at $35.17, and generate the best unit economics in the portfolio. Storefront already represents 17% of total orders — growing its share, particularly in high-volume Tier 1 markets, would improve margin without requiring new customer acquisition.

---

## Section 2: Operational Analysis — Supply Side

### Four locations are in a kitchen crisis

The most urgent finding in this analysis is the operational state of four restaurant locations: CHIP_1003 in San Francisco, CHIP_1007 in Chicago, CHIP_1011 in Brooklyn, and CHIP_1015 in Nashville.

| Restaurant | City | Sept prep time | Nov prep time | Monthly change |
|---|---|---|---|---|
| CHIP_1003 | San Francisco | 21.4 mins | 27.8 mins | +3.2 mins/month |
| CHIP_1007 | Chicago | 22.2 mins | 28.1 mins | +2.9 mins/month |
| CHIP_1011 | Brooklyn | 22.1 mins | 28.0 mins | +3.0 mins/month |
| CHIP_1015 | Nashville | 21.8 mins | 28.0 mins | +3.1 mins/month |

The benchmark for healthy locations is 13–14 minutes. These four are operating at double the benchmark and deteriorating at approximately 3 minutes per month — every month, consistently, without reversal.

Every other 19 locations fluctuate randomly within ±1 minute month over month. That is normal kitchen variance. The pattern at these four is not random — it is a systematic, accelerating deterioration that points to a structural problem at each kitchen.

One observation worth noting: all four locations are deteriorating at nearly identical rates despite being in different cities and market tiers. This could be coincidence, but it is also consistent with a shared operational change — a new menu item, a process update, or a platform-side change — that affected these locations disproportionately. Ruling this in or out early would significantly narrow the investigation.

If the current trend continues, these four locations will reach 31–34 minute prep times by February 2025. At that threshold, total fulfillment times push into a range where DoorDash's algorithm is likely to begin suppressing a restaurant's search visibility — making this a near-term risk, not a hypothetical one.

### The problem is kitchen-side, not supply-side

This distinction matters for accountability and for the fix. The analysis confirms with high confidence that the problem sits entirely within Chipotle's kitchen operations, not DoorDash's delivery supply.

Evidence:
- Average delivery time across all 23 restaurants: 15.05–15.25 minutes. The four underperformers: 15.07–15.25 minutes. Identical.
- Average driver rating across all 23 restaurants: 4.57–4.60. The four underperformers: 4.57–4.59. Identical.
- Average restaurant acceptance time: 1.95–2.03 minutes across all locations. No difference.

The only metric that separates the four underperformers from the rest is prep time. Everything downstream of the kitchen — driver assignment, driver wait, delivery, driver performance — is functioning normally.

The four underperformers also show elevated driver wait times (4.9–5.0 minutes vs 2.7–2.9 minutes for healthy locations). This is a direct consequence of slow kitchens making Dashers wait at the restaurant — not a separate supply issue. The causal chain is clear: slow kitchen → longer driver wait → longer total fulfillment time → lower customer ratings.

Refund rates at these four locations (3.1–3.4%) are more than double the benchmark (1.2–1.6%). Restaurant ratings have deteriorated to 3.3–3.6 vs 4.49–4.52 at healthy locations. The customer impact is already visible and worsening.

### Tier 3 has a separate and different problem

The four underperformer locations are a restaurant-specific kitchen throughput problem. Tier 3 (Denver and Minneapolis) has a market-level reliability problem that is distinct in both cause and required response.

Denver's cancellation rate is 8.5% — three times higher than Chicago (2.8%) and San Francisco (3.0%). Minneapolis is at 6.7%. Tier 2 cities sit between 4.9% and 5.1%. The Tier 3 step-change is not explained by the four kitchen underperformers — those locations are in SF, Chicago, Brooklyn, and Nashville, not in Tier 3 markets.

The type of cancellation driving this matters. Denver shows a disproportionately high share of `restaurant_closed` cancellations — orders placed when a Chipotle location is unexpectedly offline or unavailable. This is not a customer behavior issue or a Dasher issue. It is a restaurant reliability issue: Denver locations appear to be going offline during active order windows more frequently than other markets.

The combined effect of high cancellations and high refund rates (Tier 3 average: 8.3% vs Tier 1: 4.2%) creates a poor customer experience that suppresses repeat ordering — and likely explains a significant portion of the new customer acquisition decline identified in the growth section.

---

## Section 3: Recommendations

Three specific actions address the most material problems identified in this analysis, ordered by urgency.

---

**1. Immediate operational intervention at four locations**

*Owner: DoorDash Merchant Success + Chipotle Operations*

CHIP_1003, CHIP_1007, CHIP_1011, and CHIP_1015 need dedicated attention before the November trend extends into Q1 2025. The root cause — staffing, equipment, training, or throughput — requires on-the-ground investigation at each location. The starting point should be determining whether a shared operational change connects these four locations; if so, the investigation scope narrows considerably. DoorDash should assign a merchant success manager to each location with a mandate to identify the cause and track weekly prep time reduction.

A measurable target: return all four locations to sub-16-minute average prep time within 60 days. That would bring total fulfillment times back to the portfolio benchmark and stop the rating deterioration. Three of these four locations are in Tier 1 markets and Nashville is one of Chipotle's strongest Tier 2 locations by per-location GMV — the volume at stake makes this the highest priority item in the analysis.

---

**2. Stabilise Tier 3 reliability before investing in growth**

*Owner: Chipotle Operations + DoorDash Market Operations*

Denver and Minneapolis should not receive growth investment until their restaurant reliability issues are resolved. Acquiring customers — including DashPass subscribers — into markets with 8.5% cancellation rates will produce churn, not a retained customer base.

Two specific actions: first, investigate why Denver locations are going offline unexpectedly during order windows and close the operational gap causing `restaurant_closed` cancellations. Second, establish a monthly reliability scorecard for Tier 3 markets with explicit targets — cancellation rate below 5%, refund rate below 5% — as a prerequisite before any paid growth investment is approved.

Resolving this also unlocks the DashPass opportunity. The two are sequentially dependent.

---

**3. DashPass growth campaign in Tier 2 and Tier 3 markets**

*Owner: DoorDash Growth + Chipotle Marketing*

The 22-point DashPass penetration gap between SF (43%) and Denver (21%) represents a quantifiable GMV opportunity. If Denver and Minneapolis reached Tier 2 penetration levels (29–32%), the incremental GMV per month across those two markets would be meaningful without any change in customer count or location footprint.

The mechanism is targeted in-app DashPass trial promotions specifically for Chipotle orders in Tier 2 and Tier 3 markets. Before designing a campaign, it is worth validating whether the penetration gap reflects a Chipotle-specific conversion opportunity or a structural market characteristic — checking DashPass adoption rates across other merchants in these cities would answer this quickly. If the gap is Chipotle-specific, the opportunity is real. If those markets are broadly low-penetration across all merchants, the lever is more limited.

This sits third because it is contingent on Tier 3 reliability work being completed first.

---

## Methodology Note

All data in this project is synthetic. The dataset was generated in Python to simulate realistic delivery marketplace behavior — including variable order volumes by market tier, organic customer acquisition and retention patterns, channel mix dynamics, DashPass penetration differences, and operational variance across locations. Four restaurant locations were specifically designed to exhibit systematic prep time deterioration.

The analytical framework, SQL structure, classification methodology, and findings narrative are modeled on how a strategy or partnerships team at a delivery marketplace would approach a quarterly business review. Full dataset design details and metric definitions are in `02_data_dictionary.md`.
