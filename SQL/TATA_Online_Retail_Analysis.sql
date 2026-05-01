-- ============================================================
-- TATA iQ ONLINE RETAIL ANALYSIS
-- Tool: PostgreSQL
-- Dataset: Online Retail (Forage - Tata iQ Simulation)
-- Analyst: Jat
-- Date: April 2026
-- ============================================================


-- CREATE RAW TABLE
-- All columns imported as TEXT to avoid type errors during import


create table online_retail (
    invoice_no TEXT,
    stock_code TEXT,
    description TEXT,
    quantity TEXT,
    invoice_date TEXT,
    unit_price TEXT,
    customer_id TEXT,
    country TEXT
);

-- Import CSV via pgAdmin Import/Export tool
-- Header: ON | Delimiter: comma
-- Raw row count after import: 541,909 rows


-- FIX DATE FORMAT
-- Dataset uses MM/DD/YY format — set PostgreSQL to read correctly


SET datestyle = 'MDY';


-- STEP 3 — CONVERT COLUMN DATA TYPES
-- Convert TEXT columns to proper types for analysis
-- :: operator means CAST/CONVERT in PostgreSQL
-- NUMERIC(10,2) = up to 10 digits total, 2 decimal places (correct for prices)


alter table online_retail
alter column quantity TYPE INTEGER using quantity::INTEGER,
alter column unit_price TYPE NUMERIC(10,2) using unit_price::NUMERIC(10,2),
alter column invoice_date TYPE TIMESTAMP using invoice_date::TIMESTAMP;


-- CREATE CLEAN TABLE
-- Remove returns (quantity < 1), pricing errors (unit_price <= 0),
-- and blank descriptions
-- Also creates Revenue column = quantity * unit_price
-- Clean row count: 530,100 rows


drop table if exists online_retail_clean;

create table online_retail_clean as
select *,
    quantity * unit_price as revenue
from online_retail
where quantity >= 1
and unit_price > 0
and description is not null
and description != '';


-- DATA VALIDATION QUERY 1 — Row Count Check
-- Verify total rows, check for nulls in key columns


select
    count(*) as total_rows,
    count(invoice_no) as invoice_no_count,
    count(customer_id) as customer_id_count,
    count(description) as description_count,
    count(*) - count(customer_id) as missing_customer_ids
from online_retail_clean;


-- DATA VALIDATION QUERY 2 — Range Check
-- Verify no negative quantities or prices slipped through
-- Check min/max values for key numeric columns


select
    MIN(quantity) as min_quantity,
    MAX(quantity) as max_quantity,
    MIN(unit_price) as min_unit_price,
    MAX(unit_price) as max_unit_price,
    MIN(revenue) as min_revenue,
    MAX(revenue) as max_revenue,
    MIN(invoice_date) as earliest_date,
    MAX(invoice_date) as latest_date
from online_retail_clean;



-- ANALYSIS QUERIES (10) — TO BE ADDED BELOW


-- Query 1 — Revenue by Country (Excluding UK)
-- Business question: Which top 10 international markets generate the most revenue and quantity?

select
    country,
    ROUND(SUM(revenue), 2) as total_revenue,
    SUM(quantity) as total_quantity,
    count(distinct invoice_no) as total_orders
from online_retail_clean
where country != 'United Kingdom'
group by country
order by total_revenue desc
limit 10;


-- Query 2 — Monthly Revenue Trend 2011
-- Business question: How did revenue trend month by month in 2011? Are there seasonal peaks?

select
    EXTRACT(MONTH from invoice_date) as month_number,
    TO_CHAR(invoice_date, 'Month') as month_name,
    ROUND(sum(revenue), 2) as total_revenue,
    COUNT(DISTINCT invoice_no) as total_orders
from online_retail_clean
where EXTRACT(YEAR from invoice_date) = 2011
group by month_number, month_name
order by month_number;


-- Query 3 — Top 10 Customers by Revenue
-- Business question: Which customers generate the most revenue and how concentrated is that value?

select
    customer_id,
    ROUND(SUM(revenue), 2) as total_revenue,
    COUNT(distinct invoice_no) as total_orders,
    SUM(quantity) as total_quantity
from online_retail_clean
where customer_id is not null
group by customer_id
order by total_revenue desc
limit 10;


-- Query 4 — Top 10 Products by Revenue
-- Business question: Which products drive the most revenue for the business?

select
    stock_code,
    description,
    ROUND(SUM(revenue), 2) as total_revenue,
    SUM(quantity) as total_quantity,
    COUNT(DISTINCT invoice_no) as total_orders
from online_retail_clean
group by stock_code, description
order by total_revenue desc
limit 10;


-- Query 5 — Repeat Customer Analysis
-- Business question: How many customers made more than one purchase? What is customer loyalty like?

select
    customer_id,
    COUNT(DISTINCT invoice_no) as total_orders,
    ROUND(SUM(revenue), 2) as total_revenue,
    MIN(DATE(invoice_date)) as first_purchase,
    MAX(DATE(invoice_date)) as last_purchase
from online_retail_clean
where customer_id is not null
group by customer_id
having COUNT(DISTINCT invoice_no) > 1
order by total_orders desc
limit 10;


-- Query 6 — Average Order Value by Country (Excluding UK)
-- Business question: Which markets have the highest value per order — not just total revenue?

select
    country,
    COUNT(DISTINCT invoice_no) as total_orders,
    ROUND(SUM(revenue), 2) as total_revenue,
    ROUND(SUM(revenue) / COUNT(DISTINCT invoice_no), 2) as avg_order_value
from online_retail_clean
where country != 'United Kingdom'
group by country
order by avg_order_value desc
limit 10;


-- Query 7 — Revenue by Quarter
-- Business question: Which quarter drives the most revenue? Is there a strong Q4 seasonal pattern?

select
    EXTRACT(YEAR FROM invoice_date) as year,
    EXTRACT(QUARTER FROM invoice_date) as quarter,
    ROUND(SUM(revenue), 2) as total_revenue,
    COUNT(DISTINCT invoice_no) as total_orders,
    SUM(quantity) as total_quantity
from online_retail_clean
group by year, quarter
order by year, quarter;


-- Query 8 — Customer Purchase Frequency Segments
-- Business question: What percentage of customers are one-time buyers vs repeat buyers?

select
    CASE
        WHEN total_orders = 1 THEN '1 - One Time Buyer'
        WHEN total_orders BETWEEN 2 AND 5 THEN '2 to 5 - Occasional Buyer'
        WHEN total_orders BETWEEN 6 AND 10 THEN '6 to 10 - Regular Buyer'
        ELSE '11 Plus - Loyal Buyer'
    END as customer_segment,
    COUNT(customer_id) as customer_count,
    ROUND(COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER (), 2) as percentage
from (
    select
        customer_id,
        COUNT(DISTINCT invoice_no) as total_orders
    from online_retail_clean
    where customer_id is not null
    group by customer_id
) as customer_orders
group by customer_segment
order by customer_segment;


-- Query 9 — Top 10 Countries by Quantity Demanded (Excluding UK)
-- Business question: Which markets have the highest product demand by volume — not just revenue?

select
    country,
    SUM(quantity) as total_quantity,
    ROUND(SUM(revenue), 2) as total_revenue,
    COUNT(DISTINCT invoice_no) as total_orders,
    RANK() OVER (order by SUM(quantity) desc) as demand_rank
from online_retail_clean
where country != 'United Kingdom'
group by country
order by total_quantity desc
limit 10;


-- Query 10 — Revenue Contribution by Country (Excluding UK) with Running Total
-- Business question: What percentage of international revenue does each country contribute — cumulatively?

select
    country,
    ROUND(SUM(revenue), 2) as total_revenue,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 2) as revenue_percentage,
    ROUND(SUM(SUM(revenue)) OVER (order by SUM(revenue) desc), 2) as running_total
from online_retail_clean
where country != 'United Kingdom'
group by country
order by total_revenue desc
limit 10;

