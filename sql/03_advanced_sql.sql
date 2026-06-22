-- ============================================================
-- Urban Ride Analytics — Advanced SQL (Window Functions & CTEs)
-- ============================================================
-- Database: ride_dw
-- Description: Demonstrates window functions, ranking,
--              running totals, CTEs, and LAG for trend analysis.
-- ============================================================

USE ride_dw;

-- ------------------------------------------------------------
-- 1. CITY REVENUE RANKING (DENSE_RANK)
-- Note: Window functions can't directly wrap an aggregate in
-- MySQL, so revenue is computed in a subquery first.
-- Insight: Which city generates the highest revenue?
-- ------------------------------------------------------------
SELECT city, revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS rank_city
FROM (
    SELECT l.city, SUM(f.booking_value) AS revenue
    FROM fact_bookings f
    JOIN dim_location l ON f.location_id = l.location_id
    GROUP BY l.city
) AS city_totals;


-- ------------------------------------------------------------
-- 2. MONTHLY REVENUE RANKING (RANK)
-- Insight: Which months perform best financially?
-- ------------------------------------------------------------
SELECT month, revenue,
    RANK() OVER (ORDER BY revenue DESC) AS rank_month
FROM (
    SELECT t.month, SUM(f.booking_value) AS revenue
    FROM fact_bookings f
    JOIN dim_time t ON f.time_id = t.time_id
    GROUP BY t.month
) AS monthly_totals;


-- ------------------------------------------------------------
-- 3. RUNNING TOTAL — CUMULATIVE REVENUE
-- Insight: Track how revenue accumulates month over month
-- ------------------------------------------------------------
SELECT
    t.month,
    SUM(f.booking_value) AS monthly_revenue,
    SUM(SUM(f.booking_value)) OVER (ORDER BY t.month) AS cumulative_revenue
FROM fact_bookings f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.month;


-- ------------------------------------------------------------
-- 4. CTE — CITIES ABOVE REVENUE THRESHOLD
-- Insight: Which cities generate more than ₹100,000 in revenue?
-- ------------------------------------------------------------
WITH city_revenue AS (
    SELECT
        l.city,
        SUM(f.booking_value) AS revenue
    FROM fact_bookings f
    JOIN dim_location l ON f.location_id = l.location_id
    GROUP BY l.city
)
SELECT * FROM city_revenue
WHERE revenue > 100000;


-- ------------------------------------------------------------
-- 5. LAG — MONTH-OVER-MONTH REVENUE GROWTH %
-- Insight: Detect growth, decline, or seasonal trends
-- ------------------------------------------------------------
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
    2) AS growth_pct
FROM (
    SELECT t.month, SUM(f.booking_value) AS revenue
    FROM fact_bookings f
    JOIN dim_time t ON f.time_id = t.time_id
    GROUP BY t.month
) AS monthly_totals
ORDER BY month;


-- ------------------------------------------------------------
-- 6. VERIFICATION — Monthly revenue check
-- Used to confirm the July revenue spike is a dataset
-- composition issue, not a data error.
-- ------------------------------------------------------------
SELECT t.month, SUM(f.booking_value) AS revenue
FROM fact_bookings f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.month
ORDER BY t.month;
