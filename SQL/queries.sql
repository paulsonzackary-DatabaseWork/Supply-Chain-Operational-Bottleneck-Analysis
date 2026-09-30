-- ============================================================
-- SUPPLY CHAIN & OPERATIONAL BOTTLENECK ANALYSIS
-- SQL ANALYSIS
-- ============================================================


-- ============================================================
-- 1. DATA OVERVIEW & QUALITY CHECKS
-- ============================================================

-- View the dataset
SELECT *
FROM public.superstore_raw;

-- Preview the first 10 rows
SELECT *
FROM public.superstore_raw
LIMIT 10;

-- Count total shipments
SELECT COUNT(*) AS total_shipments
FROM public.superstore_raw;


-- Check total shipments and missing values for key columns
SELECT 
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Shipment_ID IS NULL) AS missing_shipment_id,
    COUNT(*) FILTER (WHERE Shipment_Date IS NULL) AS missing_shipment_date,
    COUNT(*) FILTER (WHERE Delivery_Date IS NULL) AS missing_delivery_date,
    COUNT(*) FILTER (WHERE Cost IS NULL) AS missing_cost,
    COUNT(*) FILTER (WHERE Weight_kg IS NULL) AS missing_weight,
    COUNT(*) FILTER (WHERE Distance_miles IS NULL) AS missing_distance,
    COUNT(*) FILTER (WHERE Transit_Days IS NULL) AS missing_transit_days
FROM public.superstore_raw;


-- ============================================================
-- 2. MISSING COST ANALYSIS
-- ============================================================

-- Identify shipments with missing costs
SELECT
    Shipment_ID,
    Shipment_Date,
    Delivery_Date,
    Cost,
    Status,
    Distance_miles,
    Transit_Days
FROM public.superstore_raw
WHERE Cost IS NULL;


-- Measure the number and percentage of shipments with missing costs
SELECT 
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Cost IS NULL) AS missing_cost,
    ROUND(
        COUNT(*) FILTER (WHERE Cost IS NULL) * 100.0 / COUNT(*),
        2
    ) AS missing_cost_percentage
FROM public.superstore_raw;

-- Finding:
-- 39 of 1,952 shipments (2.00%) have missing cost values.


-- Identify shipment statuses associated with missing costs
SELECT
    Status,
    COUNT(*) AS missing_cost_shipments
FROM public.superstore_raw
WHERE Cost IS NULL
GROUP BY Status
ORDER BY missing_cost_shipments DESC;

-- Finding:
-- 34 of 39 shipments with missing costs are marked Delivered,
-- while 5 are marked Delayed.


-- Identify carriers associated with missing costs
SELECT
    Carrier,
    COUNT(*) AS missing_cost_shipments
FROM public.superstore_raw
WHERE Cost IS NULL
GROUP BY Carrier
ORDER BY missing_cost_shipments DESC;


-- Compare missing-cost rates across carriers
SELECT 
    Carrier,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Cost IS NULL) AS missing_cost_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE Cost IS NULL) * 100.0 / COUNT(*),
        2
    ) AS missing_cost_percentage
FROM public.superstore_raw
GROUP BY Carrier
ORDER BY missing_cost_percentage DESC;

-- Finding:
-- USPS has the highest missing-cost rate at 3.89%,
-- while FedEx has the lowest at 0.34%.


-- ============================================================
-- 3. DATA INTEGRITY CHECKS
-- ============================================================

-- Identify duplicate Shipment IDs
SELECT
    Shipment_ID,
    COUNT(*) AS shipment_count
FROM public.superstore_raw
GROUP BY Shipment_ID
HAVING COUNT(*) > 1;


-- Check for invalid transit dates
SELECT
    Shipment_ID,
    Shipment_Date,
    Delivery_Date,
    Transit_Days_Calculated,
    Invalid_Transit_Date
FROM public.superstore_raw
WHERE Invalid_Transit_Date = TRUE;

-- Finding:
-- No invalid transit dates were found.


-- Identify shipments with missing delivery dates
SELECT
    Shipment_ID,
    Shipment_Date,
    Delivery_Date,
    Status,
    Cost
FROM public.superstore_raw
WHERE Delivery_Date IS NULL;


-- ============================================================
-- 4. OVERALL OPERATIONAL PERFORMANCE
-- ============================================================

-- Shipment distribution by status
SELECT
    Status,
    COUNT(*) AS shipment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_shipments
FROM public.superstore_raw
GROUP BY Status
ORDER BY shipment_count DESC;


-- Average transit time by shipment status
SELECT 
    Status,
    COUNT(*) AS shipment_count,
    ROUND(AVG(Transit_Days_Calculated), 2) AS avg_transit_days
FROM public.superstore_raw
WHERE Transit_Days_Calculated IS NOT NULL
GROUP BY Status
ORDER BY avg_transit_days DESC;

-- Finding:
-- Delayed shipments average 11.46 days in transit,
-- compared with 4.21 days for delivered shipments.


-- ============================================================
-- 5. CARRIER PERFORMANCE
-- ============================================================

-- Average transit time by carrier
SELECT
    Carrier,
    COUNT(*) AS shipment_count,
    ROUND(AVG(Transit_Days_Calculated), 2) AS avg_transit_days
FROM public.superstore_raw
WHERE Transit_Days_Calculated IS NOT NULL
GROUP BY Carrier
ORDER BY avg_transit_days DESC;


-- Delay rate by carrier
SELECT
    Carrier,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE Status = 'Delayed') * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM public.superstore_raw
GROUP BY Carrier
ORDER BY delay_rate_percentage DESC;

-- Finding:
-- DHL has the highest observed delay rate at 13.87%,
-- while USPS has the lowest at 7.07%.


-- Average shipping cost by carrier
SELECT
    Carrier,
    COUNT(*) AS total_shipments,
    ROUND(AVG(Cost), 2) AS avg_shipping_cost
FROM public.superstore_raw
WHERE Cost IS NOT NULL
GROUP BY Carrier
ORDER BY avg_shipping_cost DESC;


-- Rank carriers by delay rate
SELECT
    Carrier,
    COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE Status = 'Delayed') * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage,
    RANK() OVER (
        ORDER BY
            COUNT(*) FILTER (WHERE Status = 'Delayed') * 100.0
            / COUNT(*) DESC
    ) AS delay_rate_rank
FROM public.superstore_raw
GROUP BY Carrier
ORDER BY delay_rate_rank;


-- ============================================================
-- 6. WAREHOUSE PERFORMANCE
-- ============================================================

-- Delay rate by origin warehouse
SELECT
    Origin_Warehouse,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE Status = 'Delayed') * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM public.superstore_raw
GROUP BY Origin_Warehouse
ORDER BY delay_rate_percentage DESC;

-- Finding:
-- Warehouse_HOU has the highest observed delay rate at 12.14%,
-- while Warehouse_NYC has the lowest at 6.02%.


-- Average transit time by origin warehouse
SELECT 
    Origin_Warehouse,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments,
    ROUND(AVG(Transit_Days_Calculated), 2) AS avg_transit_days
FROM public.superstore_raw
WHERE Transit_Days_Calculated IS NOT NULL
GROUP BY Origin_Warehouse
ORDER BY avg_transit_days DESC;


-- ============================================================
-- 7. TIME-BASED ANALYSIS
-- ============================================================

-- Monthly shipment volume and delay rate
SELECT
    DATE_TRUNC('month', Shipment_Date) AS shipment_month,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE Status = 'Delayed') * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM public.superstore_raw
GROUP BY shipment_month
ORDER BY shipment_month;


-- ============================================================
-- 8. CTE ANALYSIS
-- ============================================================

-- Use a CTE to calculate carrier delay rates
WITH carrier_performance AS (
    SELECT
        Carrier,
        COUNT(*) AS total_shipments,
        COUNT(*) FILTER (WHERE Status = 'Delayed') AS delayed_shipments
    FROM public.superstore_raw
    GROUP BY Carrier
)
SELECT
    Carrier,
    total_shipments,
    delayed_shipments,
    ROUND(
        delayed_shipments * 100.0 / total_shipments,
        2
    ) AS delay_rate_percentage
FROM carrier_performance
ORDER BY delay_rate_percentage DESC;


-- Average shipping cost by shipment status
SELECT
    Status,
    COUNT(*) AS shipment_count,
    ROUND(AVG(Cost), 2) AS avg_shipping_cost
FROM public.superstore_raw
WHERE Cost IS NOT NULL
GROUP BY Status
ORDER BY avg_shipping_cost DESC;