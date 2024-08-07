-- !!! Read the README.md file and this script thoroughtly. Ensure database is created and populated before executing this script. !!!

USE adventureworks2022;

-- Create VIEW, sales_combined, by joining all sales tables. 
CREATE OR REPLACE VIEW sales_combined AS
SELECT * FROM sales_2020
UNION 
SELECT * FROM sales_2021
UNION 
SELECT * FROM sales_2022;

/* !!! EXECUTE THIS CODE ONCE !!! 
   Each subsequent execution will add 18 more years to the BirthDate column. Use -18 to go back 18 years.
   For the purpose of this analysis the first BirthDate must be 1984-04-08, changed from 1966-04-08. */ 
   
-- Alter BirthDate column in customers table by adding 18 years. 
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET BirthDate = DATE_ADD(BirthDate, INTERVAL 18 YEAR);
SET SQL_SAFE_UPDATES = 1;


-- Q1. What was each country's sales by customer age group?

-- Fetch countries, calculate age and sales by joining the necessary tables using a Common Table Expression (CTE).  
WITH cte_age AS
      (SELECT t.Country,
       TIMESTAMPDIFF(YEAR, c.BirthDate, s.OrderDate) AS Age,
      (s.OrderQuantity * p.ProductPrice) AS Sales
      FROM territories t 
      JOIN sales_combined s  
      ON s.TerritoryKey = t.SalesTerritoryKey 
      JOIN products p 
      ON s.ProductKey = p.ProductKey
      JOIN customers c 
      ON s.CustomerKey = c.CustomerKey)
-- Group ages into bins/buckets and calculate sales by age group.
SELECT Country,
	   CASE 
	       WHEN Age < 30 THEN 'a. Under 30'
	       WHEN Age BETWEEN 30 AND 39 THEN 'b. 30-39'
	       WHEN Age BETWEEN 40 AND 49 THEN 'c. 40-49'
	       WHEN Age BETWEEN 50 AND 59 THEN 'd. 50-59'
	       WHEN Age >= 60 THEN 'e. Over 60'
	       ELSE 'Other'
        END AS AgeGroup,
	    ROUND(SUM(Sales), 2) AS Sales
FROM cte_age 
GROUP BY Country,
        CASE 
	    WHEN Age < 30 THEN 'a. Under 30'
	    WHEN Age BETWEEN 30 AND 39 THEN 'b. 30-39'
	    WHEN Age BETWEEN 40 AND 49 THEN 'c. 40-49'
	    WHEN Age BETWEEN 50 AND 59 THEN 'd. 50-59'
	    WHEN Age >= 60 THEN 'e. Over 60'
	    ELSE 'Other'
        END
ORDER BY Country, AgeGroup;


-- Q2. Show the quantity of product subcategory sales by customer age group.

-- Fetch product subcategories, calculate age and sales by joining the necessary tables, using a (CTE).  
WITH cte_age AS
      (SELECT ps.SubcategoryName,
       TIMESTAMPDIFF(YEAR, c.BirthDate, s.OrderDate) AS Age,
       s.OrderQuantity 
      FROM product_subcategories ps 
      JOIN products p 
      ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
      JOIN sales_combined s 
      ON p.ProductKey = s.ProductKey
      JOIN customers c 
      ON s.CustomerKey = c.CustomerKey)
-- Group ages into bins/buckets and calculate sales by age group.
SELECT SubcategoryName AS ProductSubcategory,
	   CASE 
	       WHEN Age < 30 THEN 'a. Under 30'
	       WHEN Age BETWEEN 30 AND 39 THEN 'b. 30-39'
	       WHEN Age BETWEEN 40 AND 49 THEN 'c. 40-49'
	       WHEN Age BETWEEN 50 AND 59 THEN 'd. 50-59'
	       WHEN Age >= 60 THEN 'e. Over 60'
	       ELSE 'Other'
        END AS AgeGroup,
	    SUM(OrderQuantity) AS QuantitySold
FROM cte_age
GROUP BY SubcategoryName,
        CASE 
	    WHEN Age < 30 THEN 'a. Under 30'
	    WHEN Age BETWEEN 30 AND 39 THEN 'b. 30-39'
	    WHEN Age BETWEEN 40 AND 49 THEN 'c. 40-49'
	    WHEN Age BETWEEN 50 AND 59 THEN 'd. 50-59'
	    WHEN Age >= 60 THEN 'e. Over 60'
	    ELSE 'Other'
        END
ORDER BY ProductSubcategory, AgeGroup;


/* Q3. Management is interested in comparing European market sales for the year 2021. 
       Show monthly sales compared for European countries in the year under review. */

-- Fetch date in 'MMM' format (eg. Jan, Feb, Mar), countries in Europe and calculate sales by joining the necessary tables. 
SELECT DATE_FORMAT(s.OrderDate, '%b') AS Month_2021,
       t.Country,
       ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Sales
FROM sales_2021 s, territories t, products p
WHERE s.TerritoryKey = t.SalesTerritoryKey 
	  AND Continent = 'Europe'
	  AND s.ProductKey = p.ProductKey
GROUP BY DATE_FORMAT(s.OrderDate, '%b'), t.Country;


-- Q4. Compare monthly sales and cumulative sales for Australia and USA for the year 2021.
	
-- Calculate cumulative monthly sales using an Aggregate Window Function and fetch results from the derived table below. 
SELECT  Month_2021, 
	Country,
        Sales,
        SUM(Sales) OVER (PARTITION BY Country ORDER BY Month_2021) AS CumulativeSales
-- Fetch date in 'MM-YYYY' format (eg. 01-2021), countries and calculate sales by joining the necessary tables using a derived table.         
FROM (SELECT DATE_FORMAT(s.OrderDate, '%m-%Y') AS Month_2021,
	     t.Country,
             SUM(s.OrderQuantity * p.ProductPrice) AS Sales
	  FROM sales_2021 s, territories t, products p
	  WHERE s.TerritoryKey = t.SalesTerritoryKey 
			AND Country IN ('Australia', 'United States')
			AND s.ProductKey = p.ProductKey
	  GROUP BY DATE_FORMAT(s.OrderDate, '%m-%Y'), t.Country) AS Year_Sales;

 
-- Q5. What was the quantity and value of returns for product categories in each Country?

-- Fetch countries, product categories, total returns and product prices using a CTE.
WITH qty_returned AS
		(SELECT t.Country,
			pc.CategoryName,
			SUM(COALESCE(r.ReturnQuantity, 0)) AS ReturnsQuantity,
			p.ProductPrice
		 FROM product_categories pc  
		 LEFT JOIN product_subcategories ps USING (ProductCategoryKey)
		 JOIN products p USING (ProductSubcategoryKey)
		 LEFT JOIN returns r USING (ProductKey)
		 LEFT JOIN territories t 
		 ON t.SalesTerritoryKey = r.TerritoryKey
		 GROUP BY t.Country, pc.CategoryName, p.ProductPrice
		 ORDER BY t.Country),
     -- Use a CTE to fetch countries, product categories, total returns and total sales.
	 returns_val AS
		(SELECT Country,
			CategoryName,
			ReturnsQuantity,
			SUM(ProductPrice * ReturnsQuantity) AS ReturnsValue
		 FROM qty_returned
		 GROUP BY Country, CategoryName, ReturnsQuantity
		 ORDER BY Country, CategoryName)
-- Calculate total sales and total returns per product category for each country.
SELECT COALESCE(Country, 'None') AS Country,
       CategoryName AS ProductCategory,
       SUM(ReturnsQuantity) AS ReturnsQuantity,
       ROUND(SUM(ReturnsValue), 2) AS ReturnsValue
FROM returns_val
GROUP BY Country, CategoryName;


-- Q6. What was the impact of returns on accessories, bikes and clothing sales in Canada?

-- Fetch product categories and calculate total sales, using a CTE. 
WITH category_sales AS
		(SELECT pc.CategoryName,
			ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Sales 
		 FROM product_categories pc
		 JOIN product_subcategories ps 
		 ON pc.ProductCategoryKey = ps.ProductCategoryKey 
		 JOIN products p
		 ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
		 JOIN sales_combined s
		 ON p.ProductKey = s.ProductKey
         WHERE pc.CategoryName IN ('Accessories', 'Bikes', 'Clothing') 
		AND s.TerritoryKey = (SELECT SalesTerritoryKey FROM territories WHERE Country = 'Canada')
         GROUP BY CategoryName
         ORDER BY CategoryName),
    -- Fetch product categories and calculate total returns, using a CTE. 
	returns_value AS
		(SELECT pc.CategoryName,
			ROUND(SUM(r.ReturnQuantity * p.ProductPrice), 2) AS ReturnsValue
		 FROM returns r
		 JOIN products p
		 ON r.ProductKey = p.ProductKey
		 JOIN product_subcategories ps
		 ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey 
		 JOIN product_categories pc
		 ON ps.ProductCategoryKey = pc.ProductCategoryKey
         WHERE pc.CategoryName IN ('Accessories', 'Bikes', 'Clothing') 
		AND r.TerritoryKey = (SELECT SalesTerritoryKey FROM territories WHERE Country = 'Canada')
         GROUP BY pc.CategoryName
         ORDER BY pc.CategoryName)
-- Calculate difference between total sales and total returns. 
SELECT cs.CategoryName AS ProductCategory,
       ROUND((cs.Sales - rv.ReturnsValue), 2) AS NetSales,
       rv.ReturnsValue,
       cs.Sales
FROM category_sales cs
JOIN returns_value rv USING (CategoryName);


/* Q7. Management is considering running a promotion on bikes to maximize revenue in the upcoming city   
       bike tour season. Show current and new prices of bikes if 15% discount is applied. */

-- Fetch the necessary columns. Calculate discount by subtracting 15%(0.15) from 1 and multiply results by price. 
SELECT ProductSKU,
       ProductName,
       SubcategoryName,
       ROUND(ProductPrice, 2) AS ProductPrice,
       ROUND(ProductPrice * (1 - 0.15), 2) AS PromotionPrice
FROM products p
JOIN product_subcategories ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
WHERE ps.ProductCategoryKey = (SELECT ProductCategoryKey 
			       FROM product_categories 
                               WHERE CategoryName = 'Bikes')
ORDER BY SubcategoryName, PromotionPrice;


/* Q8. Using CustomerKey fetch the sales value of each customer's first purchase item and last purchase item? 
       Indicate the difference between the last and first purchase values and show results for first 1000 customers. */

-- Fetch columns and calculate sales per purchase item into a Temporary Table.  
DROP TEMPORARY TABLE IF EXISTS sales_amount;
CREATE TEMPORARY TABLE IF NOT EXISTS sales_amount AS
SELECT s.OrderDate, 
       c.CustomerKey, 
       c.FirstName,
       c.LastName,
       (s.OrderQuantity * p.ProductPrice) AS Amount
FROM sales_combined s 
JOIN customers c
ON s.CustomerKey = c.CustomerKey
JOIN products p 
ON p.ProductKey = s.ProductKey;
-- Number each row of purchases grouped by customer key, using a CTE and Ranking Window Function.
WITH purchase_row AS 
		(SELECT OrderDate, 
			CustomerKey, 
			Amount,
			ROW_NUMBER() OVER (PARTITION BY CustomerKey ORDER BY OrderDate) AS PurchaseNum
		 FROM sales_amount),
	 -- Fetch the value of first purchase items and last purchase items using a CTE and Analytical/Value Window Functions. 
	 purchase_value AS
	    (SELECT CustomerKey,
	            FIRST_VALUE(Amount) OVER (PARTITION BY CustomerKey) AS FirstPurchaseValue,
                    LAST_VALUE(Amount) OVER (PARTITION BY CustomerKey) AS LastPurchaseValue
	     FROM purchase_row)
-- Fetch customer keys, first purchase values, last purchase values and their differences.        
SELECT DISTINCT CustomerKey,
		FirstPurchaseValue,
       		LastPurchaseValue,
       		ROUND((LastPurchaseValue - FirstPurchaseValue), 2) AS Difference
FROM purchase_value
LIMIT 1000;
		

-- Q9. Show the number of bike purchases by Income.

-- Fetch customer key, product category, annual income and order number columns by joining the necessary tables and then filter out bikes.
WITH bike_purchases AS 
	(SELECT c.CustomerKey, 
		pc.CategoryName,
        	c.AnnualIncome,
            	s.OrderNumber
	  FROM product_categories pc
	  JOIN product_subcategories ps 
	  ON pc.ProductCategoryKey = ps.ProductCategoryKey 
	  JOIN products p
	  ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	  JOIN sales_combined s
	  ON p.ProductKey = s.ProductKey
	  JOIN customers c
	  ON c.CustomerKey = s.CustomerKey
	  WHERE pc.CategoryName = 'Bikes')
-- Group annual income into bins/buckets and count number of bikes per group. 
SELECT CustomerKey, 
	   CASE 
	       WHEN AnnualIncome < 50000 THEN 'a. Under $50k'
	       WHEN AnnualIncome BETWEEN 50000 AND 75000 THEN 'b. $50k - $75k'
	       WHEN AnnualIncome BETWEEN 75000 AND 100000 THEN 'c. $75k - $100k'
	       WHEN AnnualIncome > 100000 THEN 'd. Over $100k'
	       ELSE 'Other'
       END AS IncomeGroup,     
	   COUNT(OrderNumber) AS Purchases 
FROM bike_purchases 
GROUP BY CustomerKey, AnnualIncome;


-- Q10. Compare number of bike purchases for customers with children and customers with no children in 2020. 

-- Fetch customer key, order date, order number, product category and total children columns by joining the necessary tables and then filter out bikes. 
WITH bike_purchases AS 
	(SELECT c.CustomerKey,
		s.OrderDate,
		s.OrderNumber,
		pc.CategoryName,
            	c.TotalChildren
	  FROM product_categories pc
	  JOIN product_subcategories ps 
	  ON pc.ProductCategoryKey = ps.ProductCategoryKey 
	  JOIN products p
	  ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	  JOIN sales_combined s
	  ON p.ProductKey = s.ProductKey
	  JOIN customers c
	  ON c.CustomerKey = s.CustomerKey
	  WHERE pc.CategoryName = 'Bikes' AND YEAR(s.OrderDate) = 2020)
-- Fetch date in 'MM-YYYY' format (eg. 01-2021) and group customers with children and no children.
SELECT DATE_FORMAT(OrderDate, '%m-%Y') AS MonthYear,
	   CASE 
	       WHEN TotalChildren = 0 THEN 'No_Children'
           ELSE 'Has_Children'
	   END AS 'Children?',
	   COUNT(OrderNumber) AS Purchases 
FROM bike_purchases 
GROUP BY DATE_FORMAT((s.OrderDate), '%m-%Y'), TotalChildren
ORDER BY MonthYear;


					        -- --- ---- -----  END OF ANALYSIS  ----- ---- --- --
