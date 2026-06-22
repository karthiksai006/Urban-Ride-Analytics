-- ============================================================
-- Urban Ride Analytics — OLAP Operations
-- ============================================================
-- Database: ride_dw
-- Description: Core OLAP operations — Roll-up, Drill-down,
--              Slice & Dice, Pivot — plus business queries for
--              cancellation rate and top customers.
-- ============================================================

USE ride_dw;

-- ------------------------------------------------------------
-- 1. ROLL-UP
-- Hierarchy: City -> Vehicle Type -> Time Slot
-- Insight: Which vehicle performs best in each city, by time slot?
-- ------------------------------------------------------------
SELECT
    l.city,
    v.vehicle_type,
    t.time_slot,
    COUNT(*)              AS total_rides,
    SUM(f.booking_value)  AS revenue
FROM fact_bookings f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_vehicle  v ON f.vehicle_id  = v.vehicle_id
JOIN dim_time     t ON f.time_id     = t.time_id
GROUP BY l.city, v.vehicle_type, t.time_slot
ORDER BY l.city;


-- ------------------------------------------------------------
-- 2. DRILL-DOWN
-- Hierarchy: Month -> Day -> Hour
-- Insight: Exact peak demand hours across days and months
-- ------------------------------------------------------------
SELECT
    t.month,
    t.day,
    t.hour,
    COUNT(*) AS rides
FROM fact_bookings f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.month, t.day, t.hour
ORDER BY t.month, t.day, t.hour;


-- ------------------------------------------------------------
-- 3. SLICE & DICE
-- Filter: Bangalore + Evening time slot only
-- Insight: Most popular vehicle type in Bangalore during evenings
-- ------------------------------------------------------------
SELECT
    v.vehicle_type,
    t.time_slot,
    COUNT(*) AS rides
FROM fact_bookings f
JOIN dim_vehicle  v ON f.vehicle_id  = v.vehicle_id
JOIN dim_time     t ON f.time_id     = t.time_id
JOIN dim_location l ON f.location_id = l.location_id
WHERE l.city = 'Bangalore'
  AND t.time_slot = 'Evening'
GROUP BY v.vehicle_type, t.time_slot;


-- ------------------------------------------------------------
-- 4. PIVOT (Cross-tab analysis)
-- Converts vehicle type rows into columns, grouped by time slot
-- Insight: Compare vehicle usage across time slots in one view
-- ------------------------------------------------------------
SELECT
    t.time_slot,
    SUM(CASE WHEN v.vehicle_type = 'Bike' THEN 1 ELSE 0 END) AS Bike,
    SUM(CASE WHEN v.vehicle_type = 'Auto' THEN 1 ELSE 0 END) AS Auto,
    SUM(CASE WHEN v.vehicle_type = 'Cab'  THEN 1 ELSE 0 END) AS Cab
FROM fact_bookings f
JOIN dim_time    t ON f.time_id    = t.time_id
JOIN dim_vehicle v ON f.vehicle_id = v.vehicle_id
GROUP BY t.time_slot;


-- ------------------------------------------------------------
-- 5. CANCELLATION RATE BY CITY
-- Insight: Which city has the highest ride cancellation rate?
-- ------------------------------------------------------------
SELECT
    l.city,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN s.booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(
        SUM(CASE WHEN s.booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS cancel_rate
FROM fact_bookings f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_status   s ON f.status_id   = s.status_id
GROUP BY l.city
ORDER BY cancel_rate DESC;


-- ------------------------------------------------------------
-- 6. TOP 10 CUSTOMERS BY SPEND
-- Insight: Identify highest-value customers
-- ------------------------------------------------------------
SELECT
    customer_id,
    SUM(booking_value) AS total_spend,
    DENSE_RANK() OVER (ORDER BY SUM(booking_value) DESC) AS rank_customer
FROM fact_bookings
GROUP BY customer_id
LIMIT 10;
