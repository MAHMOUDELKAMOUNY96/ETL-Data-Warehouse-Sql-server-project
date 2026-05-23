CREATE DATABASE ETL

USE ETL

CREATE TABLE Orders (
    Order_ID INT,
    Product VARCHAR(50),
    Quantity INT
);

CREATE TABLE Returns (
    Order_ID INT,
    Return_Quantity INT
);

INSERT INTO Orders VALUES
(1, 'A', 10),
(2, 'B', 5),
(3, 'A', 8),
(4, 'C', 12);

INSERT INTO Returns VALUES
(1, 2),
(2, 1),
(3, 4);

SELECT * FROM Orders;

SELECT * FROM Returns;

SELECT
    o.Order_ID,
    o.Product,
    o.Quantity,
    r.Return_Quantity
FROM Orders o
LEFT JOIN Returns r
ON o.Order_ID = r.Order_ID;

--  CREATE CLEAN FACT TABLE
SELECT
    o.Order_ID,
    o.Product,
    o.Quantity,

    ISNULL(r.Return_Quantity, 0) AS Return_Quantity,

    CAST(
        ISNULL(r.Return_Quantity, 0) * 1.0 / o.Quantity
        AS DECIMAL(5,2)
    ) AS Return_Rate_Row

INTO Orders_With_Returns_Clean

FROM Orders o
LEFT JOIN Returns r
ON o.Order_ID = r.Order_ID;

-- 2nd way to create clean fact table

CREATE TABLE Orders_With_Return_Clean (
    Order_ID INT PRIMARY KEY,
    Product VARCHAR(10),
    Quantity INT,
    Return_Quantity INT,
    Return_Rate_Row DECIMAL(5,2)
);

insert into Orders_With_Return_Clean
select 
o.Order_ID,
o.product,
o.Quantity,
ISNULL(r.Return_Quantity,0) ,
 ISNULL(r.Return_Quantity, 0) * 1.0 / o.Quantity
 FROM Orders o
LEFT JOIN Returns r
ON o.Order_ID = r.Order_ID;

select * from Orders_With_Return_Clean


 ---DATA VALIDATIO

-- Check NULLs
SELECT *
FROM Orders_With_Returns_Clean
WHERE Product IS NULL;

SELECT *
FROM Orders_With_Returns_Clean
WHERE Return_Quantity IS NULL;


-- Check Duplicates
SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM Orders_With_Returns_Clean
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- AGGREGATION ANALYSIS

SELECT
    Product,
    SUM(Quantity) AS Total_Quantity,
    SUM(Return_Quantity) AS Total_Returns
FROM Orders_With_Returns_Clean
GROUP BY Product;


SELECT
    AVG(Return_Rate_Row) AS Avg_Return_Rate
FROM Orders_With_Returns_Clean;


-- FEATURE ENGINEERING
ALTER TABLE Orders_With_Returns_Clean
ADD Is_High_Return BIT;

update Orders_With_Returns_Clean
set Is_High_Return =
           case
		   when Return_Rate_Row> 0.3 then 1
		   else 0
		   end
-- VIEW HIGH RETURN ORDERS
select * from  Orders_With_Returns_Clean
where Is_High_Return =1

-- ADD ORDER_DATE TO FACT TABLE
ALTER TABLE Orders_With_Returns_Clean
ADD Order_Date DATE;

UPDATE Orders_With_Returns_Clean

SET Order_Date =
    CASE
        WHEN Order_ID = 1 THEN '2025-01-01'
        WHEN Order_ID = 2 THEN '2025-01-02'
        WHEN Order_ID = 3 THEN '2025-01-03'
        WHEN Order_ID = 4 THEN '2025-01-04'
    END;


--FINAL FACT TABLE
select * from Orders_With_Returns_Clean


---Dimensions Tables
--1) dim product
CREATE TABLE Dim_Product (

    Product_ID INT IDENTITY(1,1) PRIMARY KEY,

    Product_Name VARCHAR(50)

);

insert into Dim_Product
select distinct product from Orders_With_Returns_Clean

select * from Dim_Product

--2) dim date
CREATE TABLE Dim_Date (

    Date_ID INT IDENTITY(1,1) PRIMARY KEY,

    Full_Date DATE,

    Year INT,

    Month INT,

    Day INT

);

insert into Dim_Date

select distinct 
Order_Date,

    YEAR(Order_Date),

    MONTH(Order_Date),

    DAY(Order_Date)

FROM Orders_With_Returns_Clean;

select * from Dim_Date

-- add product_id , date_id to facttable
alter table  Orders_With_Returns_Clean
add Product_ID int 

alter table  Orders_With_Returns_Clean
add Date_ID int 

update f
set f.Product_ID= d.Product_ID
from  Orders_With_Returns_Clean f
inner join Dim_Product d
on f.product = d.Product_Name

update f
set f.Date_ID= d.Date_ID
from  Orders_With_Returns_Clean f
inner join Dim_Date d
on f.Order_Date = d.Full_Date


--FINAL FACT TABLE
select * from Orders_With_Returns_Clean



---Stored_Procedure

/* ============================================
   STORED PROCEDURE
============================================ */

CREATE PROCEDURE Load_Data_Warehouse

AS

BEGIN

    -- Insert new products into Dim_Product

    INSERT INTO Dim_Product (Product_Name)

    SELECT DISTINCT Product

    FROM Orders_With_Returns_Clean

    WHERE Product NOT IN (

        SELECT Product_Name
        FROM Dim_Product

    );


    -- Update Product_ID in Fact Table

    UPDATE F

    SET F.Product_ID = D.Product_ID

    FROM Orders_With_Returns_Clean F

    JOIN Dim_Product D
        ON F.Product = D.Product_Name;


    -- Update High Return Flag

    UPDATE Orders_With_Returns_Clean

    SET Is_High_Return =
        CASE
            WHEN Return_Rate_Row > 0.30 THEN 1
            ELSE 0
        END;

END;

execute Load_Data_Warehouse
-------------------------------------------------------------------------------------------------


   ---STAR SCHEMA MODELING

-- Fact Table:
-- Orders_With_Returns_Clean

-- Dimension Tables:
-- Dim_Product
-- Dim_Date

-- Relationships:
-- Product_ID
-- Date_ID



  --- AUTOMATION CONCEPT

-- Stored Procedure created

-- Can later automate using:
-- SQL Server Agent
-- Task Scheduler
-- Batch File + sqlcmd








