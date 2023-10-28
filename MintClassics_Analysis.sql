CREATE DATABASE MINTCLASSICS;
USE MINTCLASSICS;

-- IMPORTED CSV, EXECUTED CODE & CREATED TABLES --
SHOW FULL TABLES;

-- -------------------------------------------------------------------------------------------------------------
-- PRELIMINARY ANALYSIS OF DATA --
-- -------------------------------------------------------------------------------------------------------------

-- PRELIMINARY ANALYSIS --
-- UNDERSTANDING SHAPE OF THE TABLES
SELECT * FROM CUSTOMERS;
SELECT * FROM EMPLOYEES;
SELECT * FROM OFFICES;
SELECT * FROM ORDERS;
SELECT * FROM ORDERDETAILS;
SELECT * FROM PAYMENTS;
SELECT * FROM PRODUCTS;
SELECT * FROM PRODUCTLINES;
SELECT * FROM WAREHOUSES;

-- COUNT
SELECT COUNT(DISTINCT PRODUCTNAME) FROM PRODUCTS;
SELECT COUNT(DISTINCT PRODUCTLINE) FROM PRODUCTLINES;
SELECT COUNT(DISTINCT WAREHOUSENAME) FROM WAREHOUSES;

-- DISTRIBUTION OF PRODUCT TYPES IN PRODUCTLINES, WAREHOUSES
SELECT PRODUCTLINE, COUNT(DISTINCT PRODUCTNAME) FROM PRODUCTS GROUP BY PRODUCTLINE;
SELECT W.WAREHOUSENAME, COUNT(DISTINCT P.PRODUCTLINE), COUNT(DISTINCT P.PRODUCTNAME) 
FROM PRODUCTS P, WAREHOUSES W
WHERE P.WAREHOUSECODE=W.WAREHOUSECODE GROUP BY W.WAREHOUSENAME;

-- -- DISTRIBUTION OF PRODUCT LINES IN WAREHOUSES
SELECT DISTINCT W.WAREHOUSENAME, P.PRODUCTLINE, SUM(P.QUANTITYINSTOCK) AS UNITS
FROM PRODUCTS P, WAREHOUSES W
WHERE W.WAREHOUSECODE=P.WAREHOUSECODE
GROUP BY P.PRODUCTLINE, W.WAREHOUSENAME
ORDER BY W.WAREHOUSENAME, P.PRODUCTLINE;

-- -------------------------------------------------------------------------------------------------------------

-- TOTAL INVENTORY
SELECT SUM(P.QUANTITYINSTOCK), SUM(OD.QUANTITYORDERED), SUM(OD.QUANTITYORDERED)/SUM(P.QUANTITYINSTOCK)*100 AS PERCENT
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE;

-- PRODUCT INVENTORY
SELECT DISTINCT PRODUCTLINE, PRODUCTNAME, SUM(QUANTITYINSTOCK)
FROM PRODUCTS 
GROUP BY PRODUCTLINE, PRODUCTNAME
ORDER BY SUM(QUANTITYINSTOCK);

-- INVENTORY VALIDITY
SELECT DISTINCT P.PRODUCTNAME, SUM(OD.QUANTITYORDERED) AS Ordered
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY P.PRODUCTNAME ORDER BY Ordered ASC;

-- TOTAL PRODUCTS IN EACH WAREHOUSE
SELECT DISTINCT W.WAREHOUSENAME, SUM(P.QUANTITYINSTOCK) AS PRODUCTSTOCK
FROM WAREHOUSES W, PRODUCTS P 
WHERE W.WAREHOUSECODE=P.WAREHOUSECODE
GROUP BY W.WAREHOUSENAME;

-- TOTAL PRODUCTS ORDERED
SELECT DISTINCT P.PRODUCTNAME, SUM(OD.QUANTITYORDERED) AS Ordered
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY P.PRODUCTNAME ORDER BY Ordered ASC;

-- REVENUE GENERATED BY EACH PRODUCT
SELECT DISTINCT P.PRODUCTNAME, SUM(P.QUANTITYINSTOCK), SUM(OD.QUANTITYORDERED * OD.PRICEEACH) AS REVENUE
FROM PRODUCTS P, ORDERDETAILS OD, ORDERS O
WHERE P.PRODUCTCODE=OD.PRODUCTCODE AND OD.ORDERNUMBER=O.ORDERNUMBER AND O.STATUS='SHIPPED'
GROUP BY P.PRODUCTNAME
ORDER BY REVENUE DESC;

-- MINIMUM POTENTIAL REVENUE FOR EACH PRODUCT
SELECT PRODUCTNAME, SUM(BUYPRICE*QUANTITYINSTOCK) AS POTENTIALSALES 
FROM PRODUCTS GROUP BY PRODUCTNAME ORDER BY POTENTIALSALES DESC;

-- TOTAL SALES ON ORDERS
SELECT SUM(OD.QUANTITYORDERED * OD.PRICEEACH) AS TOTALSALES
FROM ORDERS O, ORDERDETAILS OD
WHERE O.ORDERNUMBER=OD.ORDERNUMBER;

-- AVERAGE SELLING PRICE OF EACH PRODUCT
SELECT P.PRODUCTNAME, AVG(OD.PRICEEACH) 
FROM ORDERDETAILS OD, PRODUCTS P
WHERE OD.PRODUCTCODE=P.PRODUCTCODE
GROUP BY P.PRODUCTNAME ORDER BY AVG(OD.PRICEEACH) DESC;

-- -------------------------------------------------------------------------------------------------------------

-- EARLIEST RECORDED ORDER AND SHIPPING DATES
SELECT MIN(ORDERDATE), MIN(SHIPPEDDATE) FROM ORDERS;

-- LATEST RECORDED ORDER AND SHIPPING DATES
SELECT MAX(ORDERDATE), MAX(SHIPPEDDATE) FROM ORDERS;

-- TOP 10 MOST POPULAR PRODUCTS
SELECT P.PRODUCTNAME, P.PRODUCTLINE, SUM(P.QUANTITYINSTOCK), SUM(OD.QUANTITYORDERED)
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY P.PRODUCTNAME, P.PRODUCTLINE ORDER BY SUM(OD.QUANTITYORDERED) DESC
LIMIT 10;

-- TOP 10 LEAST POPULAR PRODUCTS
SELECT P.PRODUCTNAME, P.PRODUCTLINE, SUM(P.QUANTITYINSTOCK), SUM(OD.QUANTITYORDERED)
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY P.PRODUCTNAME, P.PRODUCTLINE ORDER BY SUM(OD.QUANTITYORDERED) ASC
LIMIT 10;

-- -------------------------------------------------------------------------------------------------------------

-- PROFIT GENERATED BY PRODUCTS
SELECT P.PRODUCTNAME, AVG(OD.PRICEEACH) AS AVGSP, P.BUYPRICE, AVG(OD.PRICEEACH)-P.BUYPRICE AS PROFIT
FROM ORDERDETAILS OD, PRODUCTS P
WHERE OD.PRODUCTCODE=P.PRODUCTCODE
GROUP BY P.BUYPRICE, P.PRODUCTNAME ORDER BY PROFIT DESC;

-- TOP 10 PROFITING PRODUCTS
SELECT P.PRODUCTNAME, SUM(OD.QUANTITYORDERED*OD.PRICEEACH) AS REVENUE
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY PRODUCTNAME ORDER BY REVENUE DESC
LIMIT 10;

-- WAREHOUSE GENERATED REVENUE
SELECT W.WAREHOUSENAME, SUM(OD.QUANTITYORDERED*OD.PRICEEACH) AS REVENUE
FROM PRODUCTS P, ORDERDETAILS OD, WAREHOUSES W
WHERE P.PRODUCTCODE=OD.PRODUCTCODE AND P.WAREHOUSECODE=W.WAREHOUSECODE
GROUP BY WAREHOUSENAME ORDER BY REVENUE DESC;

-- 10 LEAST PROFITING PRODUCTS
SELECT P.PRODUCTNAME, SUM(OD.QUANTITYORDERED*OD.PRICEEACH) AS REVENUE
FROM PRODUCTS P, ORDERDETAILS OD
WHERE P.PRODUCTCODE=OD.PRODUCTCODE
GROUP BY PRODUCTNAME ORDER BY REVENUE ASC
LIMIT 10;

-- TOP 10 PROFITING CUSTOMERS
SELECT C.CUSTOMERNAME, COUNT(O.ORDERNUMBER) AS TOTALORDERS
FROM CUSTOMERS C, ORDERS O
WHERE C.CUSTOMERNUMBER=O.CUSTOMERNUMBER
GROUP BY CUSTOMERNAME ORDER BY TOTALORDERS DESC LIMIT 10;