-- ecommerce data 

SELECT * FROM ecommerce_sales;

-- sales trend over time ----------------------------------

-- Yearly Sales 

WITH transaction_data AS (
    SELECT 
        YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS Year,  
       ROUND(Sales, 2) AS Sales, 
        Quantity, 
        ROUND(Profit, 2) AS Profit
    FROM ecommerce_sales
) 
SELECT 
    Year, 
    ROUND(SUM(Sales), 2) AS Total_Sales,  
    ROUND(SUM(Profit), 2) AS Total_Profit,  
    SUM(Quantity) AS Total_Quantity  
FROM transaction_data
GROUP BY Year
ORDER BY Year
;

-- Yearly sales by Segment 

WITH transaction_data AS (
    SELECT 
        YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS Year,  
       Segment,
       ROUND(Sales, 2) AS Sales, 
        Quantity, 
        ROUND(Profit, 2) AS Profit
    FROM ecommerce_sales
) 
SELECT 
    Year, 
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales,  
    ROUND(SUM(Profit), 2) AS Total_Profit,  
    SUM(Quantity) AS Total_Quantity  
FROM transaction_data
GROUP BY Year, Segment  
ORDER BY Year
;


-- quarterly sales 

WITH transaction_data AS (
    SELECT 
        CONCAT(YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')), '-Q', QUARTER(STR_TO_DATE(order_date, '%m/%d/%Y'))) AS Quarter,  
        ROUND(Sales, 2) AS Sales, 
        Quantity, 
        ROUND(Profit, 2) AS Profit
    FROM ecommerce_sales
) 
SELECT 
    Quarter, 
	ROUND(SUM(Sales),2) AS Total_Sales,  
    ROUND(SUM(Profit),2) AS Total_Profit,  
    ROUND(SUM(Quantity),2) AS Total_Quantity  
FROM transaction_data
GROUP BY Quarter  
ORDER BY Quarter;

-- monthly sales 

WITH transaction_data AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(order_date, '%m/%d/%Y'), '%Y-%m') AS Date,  
        ROUND(Sales, 2) AS Sales, 
        Quantity, 
        ROUND(Profit, 2) AS Profit
    FROM ecommerce_sales
) 
SELECT 
    Date, 
    ROUND(SUM(Sales),2) AS Total_Sales,  
    ROUND(SUM(Profit),2) AS Total_Profit,  
    ROUND(SUM(Quantity),2) AS Total_Quantity  
FROM transaction_data
GROUP BY Date  
ORDER BY Date;

-- Top Products by Sales Volume ------------------------------------------

-- Number of Products 

SELECT 
	COUNT(DISTINCT product_name) AS "Number of Products" 
FROM ecommerce_sales
;

-- Top 50 Product Sales by Quantity 

SELECT 
    product_name AS Product, 
    SUM(Quantity) AS total_quantity,  
    ROUND(SUM(sales), 2) AS total_sales, 
    ROUND(SUM(profit), 2) AS total_profit
FROM 
    ecommerce_sales
GROUP BY 
    product_name  
ORDER BY 
    total_quantity DESC  
LIMIT 50
;

-- Top 10 Products with the Highest Average Profit per Sale

SELECT 
    product_name AS Product, 
    ROUND(AVG(profit), 2) AS avg_profit_per_sale,
    ROUND(SUM(sales), 2) AS total_sales,
    SUM(Quantity) AS total_quantity
FROM ecommerce_sales
GROUP BY product_name
ORDER BY avg_profit_per_sale DESC
LIMIT 10;

-- Seasonal Sales Trend (by Quarter)

SELECT 
    product_name AS Product,
	CONCAT(YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')), '-Q', QUARTER(STR_TO_DATE(order_date, '%m/%d/%Y'))) AS Quarter,  
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM ecommerce_sales
GROUP BY Product, quarter
ORDER BY Product, quarter;

-- Top 10 Most Discounted Products 

SELECT 
    product_name AS Product,
    ROUND(AVG(discount), 2) AS avg_discount,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM ecommerce_sales
GROUP BY product_name
ORDER BY avg_discount DESC
LIMIT 10
;

-- Products with Highest Sales Growth Over the Last Year

WITH yearly_sales AS (
    SELECT 
        product_name AS Product,
        YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
        SUM(sales) AS total_sales
    FROM ecommerce_sales
    GROUP BY product_name, YEAR(STR_TO_DATE(order_date, '%m/%d/%Y'))
)
SELECT 
    y1.Product,
    y1.year AS current_year,
    ROUND(y1.total_sales,2) AS current_year_sales,
    ROUND(COALESCE(y2.total_sales, 0),2) AS previous_year_sales,
    ROUND(
        CASE 
            WHEN COALESCE(y2.total_sales, 0) > 0 THEN ((y1.total_sales - y2.total_sales) / y2.total_sales) * 100
            ELSE 0 
        END, 2
    ) AS sales_growth
FROM yearly_sales y1
LEFT JOIN yearly_sales y2 
    ON y1.Product = y2.Product AND y1.year = y2.year + 1
ORDER BY sales_growth DESC
LIMIT 10;

-- Sales by Region ----------------------------------------------------

-- All Sales by Region

WITH location_sales AS (
    SELECT 
        STR_TO_DATE(order_date, '%m/%d/%Y') AS Order_Date, 
        Country, City, State, Region, Segment, 
        Quantity, Sales, Profit
    FROM 
        ecommerce_sales
)
SELECT 
    Order_Date,
    State, 
    Segment,  
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(Sales), 2) AS Total_Sales, 
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM 
    location_sales
GROUP BY 
    Order_Date, State, Segment  
ORDER BY 
    Order_Date, State;

-- Total Sales by State 

WITH location_sales AS (
    SELECT 
        STR_TO_DATE(order_date, '%m/%d/%Y') AS Order_Date, 
        Country, City, State, Region, Segment, 
        Quantity, Sales, Profit
    FROM 
        ecommerce_sales
)
SELECT 
    State, 
    ROUND(SUM(Sales), 2) AS Total_Sales,  
    ROUND(SUM(Quantity), 2) AS Total_Quantity
FROM 
    location_sales
GROUP BY 
    State  
ORDER BY 
    Total_Sales DESC;  
    
    
    -- Sum by State 
    
    WITH location_sales AS (
    SELECT 
        STR_TO_DATE(order_date, '%m/%d/%Y') AS Order_Date, 
        Country, City, State, Region, Segment, 
        Quantity, Sales, Profit
    FROM 
        ecommerce_sales
)
SELECT 
    State, 
    SUM(Quantity) AS Total_Quantity, 
    ROUND(SUM(Sales), 2) AS Total_Sales,  
    ROUND(SUM(Profit), 2) AS Total_Profit 
FROM 
    location_sales
GROUP BY 
    State 
ORDER BY 
    State;
    
    -- Annual Performance by State
    
    WITH location_sales AS (
	SELECT 
        STR_TO_DATE(order_date, '%m/%d/%Y') AS Order_Date, 
        Country, City, State, Region, 
        Quantity, Sales, Profit
    FROM ecommerce_sales
)
SELECT 
    YEAR(Order_Date) AS Year,
    State, 
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM location_sales
GROUP BY Year, State
ORDER BY State, Year, Total_Quantity DESC;

-- Customer Segmentation Based on Sales Data --------------------------------

-- 30 Most Profitable Customers 

SELECT 
	customer_name AS Customer, 
	SUM(Quantity) AS Quantity,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Customer
ORDER BY Total_Profit DESC
LIMIT 30
;

-- 30 Most Frequent Customers 

SELECT 
	customer_name AS Customer, 
	SUM(Quantity) AS Quantity,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Customer
ORDER BY Quantity DESC
LIMIT 30
;

-- Best Customer Per Quarter 

WITH transaction_data AS (
    SELECT 
        CONCAT(YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')), '-Q', QUARTER(STR_TO_DATE(order_date, '%m/%d/%Y'))) AS Quarter,  
        customer_name AS Customer, 
        ROUND(Sales, 2) AS Sales, 
        Quantity, 
        ROUND(Profit, 2) AS Profit
    FROM ecommerce_sales
) ,
quarterly_sales AS (
    SELECT 
        Quarter,
        Customer,
        ROUND(SUM(Sales), 2) AS Total_Sales,  
        ROUND(SUM(Profit), 2) AS Total_Profit,  
        SUM(Quantity) AS Total_Quantity,
        ROW_NUMBER() OVER (PARTITION BY Quarter ORDER BY SUM(Sales) DESC) AS sales_rank
    FROM transaction_data
    GROUP BY Quarter, Customer
)
SELECT 
    Quarter,
    Customer,
    Total_Sales,
    Total_Profit,
    Total_Quantity
FROM quarterly_sales
WHERE sales_rank = 1
ORDER BY Quarter
;

-- Shipping Data -----------------------------

-- Shipping Data by Year

WITH ship_data AS
(
SELECT 
    ship_mode AS Shipping_Mode,
    YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM ecommerce_sales
GROUP BY ship_mode, YEAR(STR_TO_DATE(order_date, '%m/%d/%Y'))
)
SELECT
	Year,
	Shipping_Mode,
    Total_Sales,
    Total_Profit,
    Total_Quantity
FROM ship_data
ORDER BY Year, Total_Sales DESC
;

-- Shipping Mode with Highest Quantity Sold 

SELECT 
    ship_mode AS Shipping_Mode,
    SUM(Quantity) AS Total_Quantity
FROM ecommerce_sales
GROUP BY ship_mode
ORDER BY Total_Quantity DESC;

-- Monthly Trend in Sales By Shipping Mode

SELECT 
    ship_mode AS Shipping_Mode,
    DATE_FORMAT(STR_TO_DATE(order_date, '%m/%d/%Y'), '%Y-%m') AS Month,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY Shipping_Mode, Month
ORDER BY Month, Shipping_Mode;

-- Shipping Mode with Highest Sales Growth (Quarterly)

WITH quarterly_sales AS (
    SELECT 
        ship_mode AS Shipping_Mode,
        CONCAT(YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')), '-Q', QUARTER(STR_TO_DATE(order_date, '%m/%d/%Y'))) AS Quarter,
        SUM(Sales) AS Total_Sales
    FROM ecommerce_sales
    GROUP BY Shipping_Mode, Quarter
)
SELECT 
    Shipping_Mode,
    Quarter,
    ROUND(Total_Sales,2) AS Total_Sales,
    ROUND(COALESCE(LAG(Total_Sales) OVER (PARTITION BY Shipping_Mode ORDER BY Quarter), 0), 2) AS Previous_Quarter_Sales,
    ROUND(COALESCE(((Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Shipping_Mode ORDER BY Quarter)) / 
            LAG(Total_Sales) OVER (PARTITION BY Shipping_Mode ORDER BY Quarter)) * 100, 0), 2) AS Sales_Growth_Percentage
FROM quarterly_sales
ORDER BY Shipping_Mode, Quarter;
 

