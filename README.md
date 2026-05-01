# Tata iQ Online Retail Analysis — SQL + Power BI

---

## Project Overview

This project is an enhanced version of the Tata iQ Data Visualisation simulation from Forage. The original task involved building a Power BI dashboard for an online retail client with two key stakeholders — the CEO and CMO. The enhancement adds a full SQL analysis layer in PostgreSQL covering data setup, cleaning, validation, and 10 business analysis queries.

**Stakeholder:** CEO and CMO of an online retail business  
**Business Question:** Where is revenue coming from, which markets and customers matter most, and what seasonal patterns exist that should drive strategy?  
**Dataset:** Online Retail — provided via Forage Tata iQ simulation  
**Period:** December 2010 — December 2011  

---

## Problem Statement

- Which international markets generate the most revenue and volume outside the UK?
- How does monthly and quarterly revenue trend across 2011?
- Which customers drive the highest revenue and how concentrated is that risk?
- Which products are the true bestsellers once postage charges are excluded?
- How many customers are one-time buyers versus loyal repeat buyers?
- Which markets have the highest average order value, not just total revenue?
- What percentage of international revenue does each country contribute cumulatively?

---

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL via pgAdmin | Data import, cleaning, validation, 10 analysis queries |
| Power BI Desktop | Data cleaning in Power Query, data modelling, DAX measures, 4-page dashboard |

---

## SQL Analysis

### Database Setup

- All 541,909 rows imported as TEXT columns to prevent type errors during import
- ALTER TABLE used to convert Quantity to INTEGER, UnitPrice to NUMERIC(10,2), InvoiceDate to TIMESTAMP
- SET datestyle = 'MDY' used to correctly parse MM/DD/YY date format before type conversion
- Clean table created filtering out returns (quantity < 1), pricing errors (unit_price <= 0), and blank descriptions
- Revenue column added as quantity × unit_price — final clean dataset: 530,100 rows

> **Note on row count difference:** SQL retained 530,100 rows while Power BI retained 227,703 rows from the same dataset. PostgreSQL's SET datestyle = 'MDY' successfully parsed date formats that Power BI's locale conversion could not recover. Both figures are documented — the difference is intentional, not an error.

---

### Data Validation

**DV Query 1 — Row Count and Null Check**  
Business Question: How many rows are in the clean dataset? Are there missing values in key columns?

- Clean table confirmed at 530,100 rows with no nulls in invoice_no or description
- 132,220 rows have no Customer ID — 25% of transactions are from unidentified buyers
- Customer-level analysis covers only the 397,880 rows with valid Customer IDs

**DV Query 2 — Range Check**  
Business Question: Are there unexpected minimum or maximum values after cleaning?

- Min quantity = 1, min unit price = £0.04 — no negatives slipped through, cleaning confirmed
- Max quantity = 80,995 and max unit price = £13,541.33 — extreme outliers present, documented as limitations
- Dataset spans December 2010 to December 2011

---

### Analysis Queries

**Query 1 — Revenue by Country (Excluding UK)**  
Business Question: Which international markets generate the most revenue and quantity?

- Netherlands leads at £285,446 across only 94 orders — bulk wholesale buyer profile
- EIRE (Ireland) second at £283,454 with 288 orders — more frequent, smaller purchases
- Top 5 markets: Netherlands, EIRE, Germany, France, Australia — priority expansion targets

**Query 2 — Monthly Revenue Trend 2011**  
Business Question: How did revenue trend month by month? Are there seasonal peaks?

- November peaks at £1,509,496 — early Christmas wholesale season
- September (£1,058,590) and October (£1,154,979) also strong — clear Q4 build-up
- December drops to £638,793 because dataset ends on 9 December — incomplete data, not a real decline

**Query 3 — Top 10 Customers by Revenue**  
Business Question: Which customers generate the most revenue?

- Customer 14646 is top buyer at £280,206 across 73 orders
- Customer 16446 spent £168,473 in just 2 orders — bulk wholesaler profile
- Heavy revenue concentration — top 10 customers represent a significant retention risk

**Query 4 — Top 10 Products by Revenue**  
Business Question: Which products drive the most revenue?

- DOTCOM POSTAGE ranks first at £206,249 — shipping charge, not a product, should be excluded
- REGENCY CAKESTAND 3 TIER is the top real product at £174,485 across 1,988 orders
- PAPER CRAFT LITTLE BIRDIE at £168,470 from 1 order — single bulk purchase anomaly

**Query 5 — Repeat Customer Analysis**  
Business Question: Which customers have the highest purchase frequency?

- Customer 12748 placed 209 orders — most frequent buyer, active across the full 13-month period
- High order count does not mean high revenue — Customer 12971 has 86 orders but only £11,190 revenue
- Most top repeat customers active since December 2010 — strong long-term loyalty signals

**Query 6 — Average Order Value by Country (Excluding UK)**  
Business Question: Which markets have the highest value per order, not just total revenue?

- Singapore leads AOV at £3,040 per order across just 7 orders — premium but low-frequency market
- Netherlands second at £3,037 AOV — confirms large wholesale order profile
- Australia at £2,430 AOV with 57 orders — high value and decent frequency, strong growth market

**Query 7 — Revenue by Quarter**  
Business Question: Which quarter drives the most revenue?

- Q4 2011 at £3,303,268 is the strongest quarter — Christmas wholesale orders dominate
- Consistent growth each quarter: Q1 £1.9M → Q2 £2.1M → Q3 £2.5M → Q4 £3.3M
- Q4 2010 covers only December — not comparable to full 2011 quarters

**Query 8 — Customer Purchase Frequency Segments**  
Business Question: What percentage of customers are one-time versus repeat buyers?

- 45.48% are occasional buyers (2–5 orders) — largest segment
- 34.42% are one-time buyers — over one third never returned, significant retention risk
- Only 7.77% are loyal buyers (11+ orders) — small but high-value segment

**Query 9 — Top 10 Countries by Quantity Demanded (Excluding UK)**  
Business Question: Which markets have the highest product demand by volume?

- Netherlands tops at 200,361 units across 94 orders — bulk wholesale confirmed
- EIRE second at 147,173 units — strongest all-round international market
- Sweden appears in quantity top 10 at 36,083 units but ranks lower in revenue — low-price volume buyers

**Query 10 — Revenue Contribution with Running Total (Excluding UK)**  
Business Question: What share of international revenue does each country contribute cumulatively?

- Netherlands (17.39%) and EIRE (17.27%) together = 34.66% of international revenue
- Top 5 markets account for 69.82% of international revenue cumulatively
- Heavy concentration — diversification into Spain and Switzerland recommended

---

## Power BI Dashboard

### Data Cleaning (Power Query)

- Fixed InvoiceDate mixed format using Change Type with Locale → English UK
- Filtered Quantity >= 1 (removed returns) and UnitPrice > 0 (removed pricing errors)
- Removed blank Description rows
- Created Revenue = Quantity × UnitPrice
- Clean dataset: 227,703 rows

### Data Model

- Created Date_Table using CALENDAR(DATE(2010,12,1), DATE(2011,12,31))
- Added Year, Month Number, Month Name, Quarter columns
- Marked as Date Table and sorted Month Name by Month Number
- Created KPI_Measures table via Enter Data for all DAX measures
- One-to-many relationship: Date_Table[Date] → Online Retail Data Set[InvoiceDate]

### Dashboard Pages

**Page 1 — Monthly Revenue Trend (CEO View)**  
- Visual: Line Chart — Month Name vs Total Revenue  
- Filter: Year = 2011 only  
- Key Finding: Peak in November at £1,509,496. Strong Q4 pattern. December drop due to incomplete data.

![Monthly Revenue Trend](https://github.com/BrindaJat/TATA-iQ-Online-Retail-Analytics/blob/main/PowerBI/1.Revenue%20Seasonality%20Analysis.png)

**Page 2 — Top 10 Countries by Revenue and Quantity (CMO View)**  
- Visual: Clustered Bar Chart — Country vs Revenue + Quantity  
- Filters: Exclude UK, Top N = 10 by Revenue  
- Key Finding: EIRE leads at £102K revenue and 54K units. European markets dominate.

![Top 10 Countries](https://github.com/BrindaJat/TATA-iQ-Online-Retail-Analytics/blob/main/PowerBI/2.Regional%20Revenue%20Performance.png)

**Page 3 — Top 10 Customers by Revenue (CMO View)**  
- Visual: Clustered Bar Chart — CustomerID vs Revenue (descending)  
- Filter: Exclude blank Customer IDs, Top N = 10  
- Key Finding: Customer 14596 at £168K is highest. Top 2 combined exceed £300K.

![Top 10 Customers]()

**Page 4 — Global Demand by Country (CEO View)**  
- Visual: Treemap — Country by Quantity, tooltip showing Revenue  
- Filter: Exclude UK  
- Theme: Dark navy (low demand) to sky blue (high demand)  
- Key Finding: Netherlands and EIRE are the largest boxes. European markets dominate international demand.

![Global Demand]()

### Theme

| Element | Color |
|---|---|
| Canvas | #003087 (Tata deep navy) |
| Visual background | #004299 |
| Accent | #00A3E0 |
| Text | #FFFFFF |
| Charts | #5BC2E7 + #FF6B35 |

---

## Key Findings

1. **Netherlands** leads international revenue at £285,446 with only 94 orders — highest AOV of any market at £3,037 per order
2. **November 2011** is the peak revenue month at £1,509,496 — Q4 alone accounts for £3.3M of the full year
3. **Top customer (14646)** generated £280,206 — top 10 customers represent a major revenue concentration risk
4. **34.42%** of customers are one-time buyers — over one third of the customer base never returned
5. **Top 5 international markets** account for 69.82% of international revenue cumulatively
6. **DOTCOM POSTAGE** appears as top revenue product at £206,249 — must be excluded for accurate product analysis
7. Revenue grew consistently each quarter in 2011: Q1 £1.9M → Q4 £3.3M — clear upward trend with strong Q4 seasonality

---

## Dataset

| Detail | Value |
|---|---|
| Source | Forage — Tata iQ Data Visualisation Simulation |
| Raw rows | 541,909 |
| Clean rows (SQL) | 530,100 |
| Clean rows (Power BI) | 227,703 |
| Period | December 2010 — December 2011 |
| Columns | InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country |

---

## Data Quality and Limitations

- SQL retained 530,100 rows vs Power BI's 227,703 — PostgreSQL date parsing handled formats Power BI could not. Difference is intentional and documented
- 132,220 rows (25%) have no Customer ID — all customer findings apply only to identified buyers
- DOTCOM POSTAGE and POSTAGE entries inflate product revenue — must be excluded in product analysis
- PAPER CRAFT LITTLE BIRDIE shows £168,470 from 1 order — bulk entry anomaly, treated as outlier
- Dataset covers only 13 months — year-on-year comparisons are not possible
- No cost or margin data — profitability analysis cannot be performed

---

## Tools and Techniques

**PostgreSQL**
- Raw table import with all TEXT columns to prevent type errors
- ALTER TABLE with USING clause for type conversion
- SET datestyle for date format handling
- Aggregate functions: SUM, COUNT, ROUND
- Window functions: SUM() OVER(), RANK() OVER()
- CASE WHEN for customer segmentation
- Subquery for frequency segmentation
- EXTRACT for date part analysis
- HAVING for post-aggregation filtering

**Power BI**
- Power Query: locale-based date fix, column type correction, calculated Revenue column
- Data Modelling: star schema with marked Date Table and one-to-many relationship
- DAX: Total Revenue measure using SUM
- Dashboard: 4-page report with Tata brand theme and page navigator buttons
- Visuals: Line Chart, Clustered Bar Chart, Treemap

---

## Analyst

**Brinda Jat** | Fresher Data Analyst | Vadodara, Gujarat  
**Simulation:** Tata iQ Data Visualisation — Forage (Certificate received)  
**Project Date:** April 2026
