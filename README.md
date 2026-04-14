# End-to-End ETL Data Warehouse Project (SQL Server)

##  Overview

This project demonstrates a complete ETL (Extract, Transform, Load) pipeline using SQL Server.
The goal is to clean, transform, and model raw data into a structured data warehouse format.

---

##  Data Sources

* Orders dataset
* Returns dataset

---

##  ETL Process

### 🔹 1. Extract

* Loaded raw data from Orders and Returns tables

### 🔹 2. Transform

* Removed duplicates and handled missing values
* Calculated Return Rate
* Created additional columns (data enrichment)
* Joined Orders and Returns tables

### 🔹 3. Load

* Built a Fact Table: `Orders_With_Returns_Clean`
* Created Dimension Tables:

  * `Dim_Product`
  * `Dim_Date`

---

## 🏗️ Data Modeling

* Implemented a **Star Schema**
* Fact Table connected with Dimension Tables using primary and foreign keys

---

##  Stored Procedure

* Created a stored procedure to update dimension tables automatically when new data is added to the fact table

---

##  Project Structure

* SQL Scripts (ETL, Data Cleaning, Data Modeling)
* Exported CSV files for analysis

---

##  Tools Used

* SQL Server
* SQL Server Management Studio (SSMS)
* CSV Export

---

##  Key Skills Demonstrated

* ETL Pipeline Development
* Data Cleaning & Transformation
* Data Modeling (Fact & Dimension Tables)
* SQL (Joins, Aggregations, Stored Procedures)

---

##  Future Improvements

* Automate execution using SQL Server Agent or Task Scheduler
* Connect to Power BI for visualization
