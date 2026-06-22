# 🚗 Urban Ride Analytics

**Data Warehouse Design & Multi-Dimensional Analysis of Uber & Ola Ride-Sharing Data**

A complete DWDM (Data Warehousing and Data Mining) project that integrates, cleans, and analyzes ride-sharing data from Bangalore and NCR — covering the full pipeline from raw CSVs to an interactive BI dashboard.

![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Cleaning-150458?logo=pandas)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Overview

This project builds a star-schema data warehouse for ride-sharing data from **Uber and Ola** operations in **Bangalore** and **NCR**, then performs OLAP analysis and visualizes insights in Power BI.

**Pipeline:** `Kaggle Datasets` → `Python ETL (Pandas)` → `MySQL Star Schema` → `OLAP & Advanced SQL` → `Power BI Dashboard`

---

## 🎯 Objectives

- Design and implement a star schema data warehouse in MySQL
- Build a complete ETL pipeline using Python and Pandas
- Perform OLAP operations — Roll-up, Drill-down, Slice & Dice, Pivot
- Write advanced analytical SQL using window functions, CTEs, and LAG/LEAD
- Build an interactive Power BI dashboard with cross-filtering slicers
- Extract business insights on demand, revenue, and cancellation behavior

---

## 📂 Repository Structure

```
Urban-Ride-Analytics/
│
├── README.md
│
├── notebooks/
│   └── UrbanRide_ETL.ipynb            # ETL pipeline (Extract, Transform, Load prep)
│
├── scripts/
│   └── UrbanRide_DB_Loader.py         # Connects to MySQL, creates tables, inserts data
│
├── sql/
│   ├── 01_create_tables.sql           # Star schema — fact + 5 dimension tables
│   ├── 02_olap_queries.sql            # Roll-up, Drill-down, Slice & Dice, Pivot
│   └── 03_advanced_sql.sql            # Window functions, CTEs, LAG/LEAD
│
├── powerbi/
│   ├── Urban_Ride_Analytics.pbix      # Power BI dashboard file
│   └── dashboard_overview.png         # Dashboard screenshot
│
├── data/
│   └── sample_final_rides_data.csv    # Sample of the cleaned dataset (first rows)
│
├── images/
│   └── star_schema_diagram.png        # Star schema ER diagram
│
└── docs/
    ├── Urban_Ride_Analytics_Report.docx   # Full project report
    └── Urban_Ride_Analytics.pptx          # Project presentation
```

---

## 📊 Dataset

| Detail | Description |
|---|---|
| **Source** | Kaggle — Bangalore & NCR ride-sharing datasets (Uber/Ola) |
| **Combined size** | ~250,000 rows |
| **Bangalore rows** | ~100,000 |
| **NCR rows** | ~150,000 |

The full cleaned dataset (`final_rides_data.csv`, ~40MB) exceeds GitHub's web upload limit, so it is hosted externally:

🔗 **[Download Full Dataset — Google Drive](https://drive.google.com/file/d/1JohQ7YvhpZpA3yY-YuuQ12fKQnfFDCdP/view?usp=sharing)**

A sample is available directly in this repo for quick reference:
📄 [`data/sample_final_rides_data.csv`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/data/sample_final_rides_data.csv)

---

## 🔄 ETL Process

Implemented in **Google Colab** using Python and Pandas.

**Extract** → Loaded Bangalore & NCR CSVs, inspected schema and data types
**Transform** → Standardized columns, normalized booking status, fixed DateTime, handled missing values, engineered time-based features
**Load** → Connected to MySQL via `mysql.connector`, inserted data into the star schema

**Key features engineered:** `Hour`, `Day`, `Month`, `Weekday`, `Is_Weekend`, `Time_Slot`

📓 Notebook: [`notebooks/UrbanRide_ETL.ipynb`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/notebooks/UrbanRide_ETL.ipynb)
🐍 DB Loader: [`scripts/UrbanRide_DB_Loader.py`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/scripts/UrbanRide_DB_Loader.py)

### Real-world challenges solved

| Challenge | Solution |
|---|---|
| Schema mismatch between datasets | Standardized column names across both sources |
| Inconsistent booking status values | Mapped to 5 canonical statuses (Completed, Cancelled by Driver, etc.) |
| NCR IDs had quote characters | Cleaned using `.str.replace('"', '')` |
| Separate Date/Time columns (NCR) | Reconstructed into a single `DateTime` field |
| MySQL rejected string IDs as `INT` | Changed `Booking_ID`/`Customer_ID` to `VARCHAR` |
| Foreign key constraint errors | Inserted dimension tables before the fact table |

---

## ⭐ Data Warehouse — Star Schema

A central fact table surrounded by 5 dimension tables, implemented in MySQL.

![Star Schema Diagram](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/images/star_schema_diagram.png)

```
                  dim_time
                     |
   dim_location — fact_bookings — dim_vehicle
                     |
                dim_payment
                     |
                dim_status
```

| Table | Type | Purpose |
|---|---|---|
| `fact_bookings` | Fact | Central table — one row per ride, stores measures + foreign keys |
| `dim_time` | Dimension | Hour, Day, Month, Weekday, Is_Weekend, Time_Slot |
| `dim_location` | Dimension | City, Pickup_Location, Drop_Location |
| `dim_vehicle` | Dimension | Vehicle_Type |
| `dim_payment` | Dimension | Payment_Method |
| `dim_status` | Dimension | Booking_Status, cancellation flags & reasons |

🗂️ Schema SQL: [`sql/01_create_tables.sql`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/sql/01_create_tables.sql)

---

## 📈 OLAP Operations

| Operation | Description |
|---|---|
| **Roll-up** | City → Vehicle Type → Time Slot aggregation |
| **Drill-down** | Month → Day → Hour for exact peak demand periods |
| **Slice & Dice** | Filtered views (e.g. Bangalore + Evening) |
| **Pivot** | Vehicle Type vs Time Slot cross-tab |
| **Cancellation Rate** | Cancellation % by city |
| **Top Customers** | Ranked by total spend |

🗂️ Queries: [`sql/02_olap_queries.sql`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/sql/02_olap_queries.sql)

### Advanced SQL

Window functions, ranking, running totals, CTEs, and LAG for month-over-month growth analysis.

🗂️ Queries: [`sql/03_advanced_sql.sql`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/sql/03_advanced_sql.sql)

---

## 📊 Power BI Dashboard

Connected directly to the MySQL warehouse with 6 visualizations and 3 interactive slicers (City, Vehicle Type, Time Slot).

![Dashboard Overview](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/powerbi/dashboard_overview.png)

📁 Dashboard file: [`powerbi/Urban_Ride_Analytics.pbix`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/powerbi/Urban_Ride_Analytics.pbix)

### Key Insights

- **Demand:** NCR leads in ride volume (0.15M) vs Bangalore (0.10M)
- **Revenue:** Bangalore generates more revenue (₹57M vs ₹52M) despite fewer rides — higher average fare per ride
- **Peak Time:** Morning is the highest demand slot (76K rides), followed by Evening (61K)
- **Vehicle Preference:** Auto leads at 20.62% of all bookings
- **Reliability:** 62.04% of rides completed; 17.96% cancelled by driver, 8.3% by customer
- **Revenue Trend:** July shows a spike — confirmed as a dataset composition pattern, not a data error

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Python (Pandas)** | ETL pipeline, data cleaning, feature engineering |
| **Google Colab** | ETL development environment |
| **MySQL 8.0** | Data warehouse — star schema hosting |
| **MySQL Workbench** | Schema design & query execution |
| **VS Code** | Python scripting for DB connection |
| **Power BI Desktop** | Dashboard & visualization |
| **Kaggle** | Original dataset source |

---

## 📄 Documentation

- 📘 [Full Project Report (.docx)](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/docs/Urban_Ride_Analytics_Report.docx)
- 📊 [Project Presentation (.pptx)](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/docs/Urban_Ride_Analytics.pptx)

---

## 🚀 How to Reproduce

1. Download the full dataset from the [Google Drive link](https://drive.google.com/file/d/1JohQ7YvhpZpA3yY-YuuQ12fKQnfFDCdP/view?usp=sharing)
2. Run [`notebooks/UrbanRide_ETL.ipynb`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/notebooks/UrbanRide_ETL.ipynb) to reproduce the cleaned dataset
3. Execute [`sql/01_create_tables.sql`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/sql/01_create_tables.sql) in MySQL to create the schema
4. Run [`scripts/UrbanRide_DB_Loader.py`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/scripts/UrbanRide_DB_Loader.py) to load data into the warehouse
5. Run the OLAP and advanced SQL scripts to explore the analysis
6. Open [`powerbi/Urban_Ride_Analytics.pbix`](https://github.com/karthiksai006/Urban-Ride-Analytics/blob/main/powerbi/Urban_Ride_Analytics.pbix) in Power BI Desktop to view the dashboard

---

## 👤 Author

**Karthik**

---

*This project was built as part of a DWDM (Data Warehousing and Data Mining) coursework project.*
