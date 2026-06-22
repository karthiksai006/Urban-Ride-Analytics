-- ============================================================
-- Urban Ride Analytics — Data Warehouse Schema (Star Schema)
-- ============================================================
-- Database: ride_dw
-- Description: Creates the central fact table and 5 dimension
--              tables used for OLAP analysis of ride-sharing data.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ride_dw;
USE ride_dw;

-- ------------------------------------------------------------
-- DIMENSION TABLE: dim_time
-- Stores time-based attributes for drill-down analysis
-- ------------------------------------------------------------
CREATE TABLE dim_time (
    time_id     INT PRIMARY KEY,
    DateTime    DATETIME,
    Hour        INT,
    Day         INT,
    Month       INT,
    Weekday     VARCHAR(20),
    Is_Weekend  BOOLEAN,
    Time_Slot   VARCHAR(20)
);

-- ------------------------------------------------------------
-- DIMENSION TABLE: dim_location
-- Stores city and pickup/drop location details
-- ------------------------------------------------------------
CREATE TABLE dim_location (
    location_id      INT PRIMARY KEY,
    City             VARCHAR(50),
    Pickup_Location  VARCHAR(100),
    Drop_Location    VARCHAR(100)
);

-- ------------------------------------------------------------
-- DIMENSION TABLE: dim_vehicle
-- Stores vehicle type information
-- ------------------------------------------------------------
CREATE TABLE dim_vehicle (
    vehicle_id    INT PRIMARY KEY,
    Vehicle_Type  VARCHAR(50)
);

-- ------------------------------------------------------------
-- DIMENSION TABLE: dim_payment
-- Stores payment method information
-- ------------------------------------------------------------
CREATE TABLE dim_payment (
    payment_id      INT PRIMARY KEY,
    Payment_Method  VARCHAR(50)
);

-- ------------------------------------------------------------
-- DIMENSION TABLE: dim_status
-- Stores booking outcome, cancellation, and incomplete ride info
-- ------------------------------------------------------------
CREATE TABLE dim_status (
    status_id                      INT PRIMARY KEY,
    Booking_Status                 VARCHAR(50),
    Cancelled_By_Customer          BOOLEAN,
    Cancelled_By_Driver            BOOLEAN,
    Cancellation_Reason_Customer   TEXT,
    Cancellation_Reason_Driver     TEXT,
    Incomplete_Rides                BOOLEAN,
    Incomplete_Reason               TEXT
);

-- ------------------------------------------------------------
-- FACT TABLE: fact_bookings
-- Central table — one row per ride booking.
-- Uses an auto-increment surrogate key (id) since booking_id
-- and customer_id are alphanumeric strings, not safe as PKs.
-- ------------------------------------------------------------
CREATE TABLE fact_bookings (
    id               INT AUTO_INCREMENT PRIMARY KEY,

    booking_id       VARCHAR(20),
    customer_id      VARCHAR(20),

    time_id          INT,
    location_id      INT,
    vehicle_id       INT,
    payment_id       INT,
    status_id        INT,

    ride_distance    FLOAT,
    booking_value    FLOAT,
    driver_rating    FLOAT,
    customer_rating  FLOAT,
    vtat             FLOAT,
    ctat             FLOAT,

    FOREIGN KEY (time_id)     REFERENCES dim_time(time_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (vehicle_id)  REFERENCES dim_vehicle(vehicle_id),
    FOREIGN KEY (payment_id)  REFERENCES dim_payment(payment_id),
    FOREIGN KEY (status_id)   REFERENCES dim_status(status_id)
);

-- Verify all tables were created
SHOW TABLES;
