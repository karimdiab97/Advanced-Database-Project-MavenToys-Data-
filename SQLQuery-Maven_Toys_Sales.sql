
use Mexico_Toy_Sales;

-----------------------------------------------------------
--------------------  Prodact Story -----------------------
-----------------------------------------------------------

	-- Create a schema
	CREATE SCHEMA chemaCalendar;

	-- Create a table within the schema
	DROP TABLE chemaCalendar.Calendar

	ALTER SCHEMA chemaCalendar
	TRANSFER [dbo].[Calendar];

------------------------

	--1) Show Details(Count, Total Units Sold, Avg Price, Total Product Sales)
	SELECT
		COUNT(DISTINCT P.Product_ID) AS Count_Products,
		SUM(S.Units) AS Total_Units_Sold,
		AVG(P.Product_Price) AS Average_Price,
		SUM(S.Units * P.Product_Price) AS Total_Product_Sales
	FROM Sales S JOIN Products P
	ON S.Product_ID = P.Product_ID;
	---------------------------------------------------
    -- create non cluster index for product name
	CREATE NONCLUSTERED INDEX non_cluster_nameProduct
	ON [dbo].[Products]([Product_Name] ASC)

    ---------------------------------------------------
	-- Insert new prodct
	INSERT INTO [Products]
			   ([Product_ID]
			   ,[Product_Name]
			   ,[Product_Category]
			   ,[Product_Cost]
			   ,[Product_Price])
		 VALUES
			   (40,
				'mohamed',
				'Games', 
				 2.9900, 
				 9.9900 )
	GO
	-- Display show new prodoct add
	SELECT * 
	From Products 
	WHERE Product_ID = 40

	GO
	-- update name new product
	UPDATE [dbo].[Products]
	   SET [Product_ID] =41,
		   [Product_Name] = 'FreeFire'
	 WHERE [Product_ID] =40
	GO
	-- Display show new prodoct add agan
	SELECT * 
	From Products 
	WHERE Product_ID = 41
	GO
	-- for deler this product
	DELETE FROM [Products]
		  WHERE Product_ID = 40
	GO
	-----------------------------------------------------------
	-----------------------------------------------------------
	-- 2) Top-selling products:									
	-- Which specific products consistently rank as top sellers in terms of units sold or revenue generated?

	SELECT TOP 5 P.Product_Name, SUM(S.Units) AS Total_Units_Sold
	FROM Products P JOIN Sales S
	ON P.Product_ID = S.Product_ID
	GROUP BY P.Product_ID, P.Product_Name
	ORDER BY Total_Units_Sold DESC;

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 2) Profitability analysis:
	-- What is the profit margin for each product, considering the cost and retail price?

	SELECT P.Product_ID, P.Product_Name AS 'Product Name', 
		   (SUM(S.Units) * (P.Product_Price - P.Product_Cost)) AS Profit_Margin
	FROM Products P JOIN Sales S ON P.Product_ID = S.Product_ID
	GROUP BY P.Product_ID, P.Product_Name, P.Product_Price, P.Product_Cost
	ORDER BY Profit_Margin DESC;

	-- product (1)
	-- net = 6
	-- sum(units) 57958
	-- 347748

	--SELECT P.Product_ID, SUM(s.Units)
	--from Products P JOIN Sales S ON P.Product_ID = S.Product_ID
	--GROUP by p.Product_ID

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 3) Geographic analysis:								
	-- Display the sum of units of a specific product regarding to the city it is sold in
		SELECT P.Product_ID, p.Product_Name, Store_City , SUM(S.Units) AS 'Sum of Units'
		FROM Products P JOIN Sales AS S
		ON P.Product_ID = S.Product_ID  JOIN Stores
		ON S.Store_ID = Stores.Store_ID
		GROUP BY P.Product_ID, Store_City, p.Product_Name
		HAVING P.Product_ID = 1
		ORDER by [Sum of Units] DESC

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- Calculate the percentage of total units for each product

	WITH ProductSales AS (
	SELECT  P.Product_ID, P.Product_Name, Store_City, SUM(S.Units) AS 'Sum of Units'
	FROM Products P JOIN Sales AS S 
	ON P.Product_ID = S.Product_ID JOIN Stores
	ON S.Store_ID = Stores.Store_ID
	GROUP BY P.Product_ID, Store_City, P.Product_Name
	HAVING P.Product_ID = 1)

	SELECT Product_ID, Product_Name, Store_City, [Sum of Units],
		CAST([Sum of Units] * 100.0 / SUM([Sum of Units]) OVER () AS DECIMAL(10, 2)) AS 'Percentage'
	FROM ProductSales
	ORDER BY [Sum of Units] DESC;

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 4) Average margin by Product Name:
	-- What is the average profit margin over a specific period (e.g., per month) for each product?

	SELECT Product_Name, AVG(Profit_Margin) AS Average_Profit_Margin
	FROM ( SELECT P.Product_Name, MONTH(S.Date) AS Month_, 
			SUM(S.Units * (P.Product_Price - P.Product_Cost)) AS Profit_Margin
			FROM Products P JOIN Sales S
			ON P.Product_ID = S.Product_ID
			GROUP BY P.Product_Name, MONTH(S.Date)) AS ProfitData
			GROUP BY Product_Name;

	-- ) Average margin by Month:
		SELECT Month_, AVG(Profit_Margin) AS Average_Profit_Margin
		FROM ( SELECT P.Product_Name, MONTH(S.Date) AS Month_, 
			   SUM(S.Units * (P.Product_Price - P.Product_Cost)) AS Profit_Margin
			   FROM Products P JOIN Sales S 
			   ON P.Product_ID = S.Product_ID
			   WHERE S.Date >= '2022-01-01' AND S.Date < '2022-12-31'
			   GROUP BY P.Product_Name, MONTH(S.Date)) AS ProfitData
			   GROUP BY Month_;

    ----------------------------------------
    ----------------------------------------
	
	-- 1. Select products whose names start with 'a'
	SELECT * FROM Products P
	WHERE P.Product_Name LIKE 'a%';
	GO
	-- 2. Find the minimum Product_Cost
	SELECT MIN(Product_Cost) AS min_cost
	FROM Products;
	GO
	-- 3. Select products with prices between 10 and 20
	SELECT * FROM Products
	WHERE Product_Price BETWEEN 10 AND 20;
	GO
	-- 4. Create a backup table named productCustomersBackup2017
	SELECT * INTO productCustomersBackup2017
	FROM Products P;
	GO
	-- 5. Order products based on the specified conditions
	SELECT P.Product_Name
	FROM Products P
	ORDER BY
	  CASE
		WHEN P.Product_Cost > 1200 THEN 1
		WHEN P.Product_Cost > 500 THEN 2
		ELSE 3
	  END;
																							
    -----------------------------------------------------------
	-----------------------------------------------------------

	-- 5) Find the top selling product categories,:
	-- Which product categories contribute the most to overall sales?

	-- Create View
		CREATE OR alter VIEW total AS 
		SELECT P.Product_Category ,SUM(s.Units) AS total_units
		FROM Sales s,Products p
		WHERE s.Product_ID=P.Product_ID
		GROUP BY P.Product_Category
		GO	
		SELECT * FROM total t
		ORDER BY total_units DESC

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 6) Calculate total profit for each product category across all stores.

	-- Create PROCEDURE
	CREATE PROCEDURE ssum
	AS 
	BEGIN
		SELECT Product_Category,
		SUM(Total_Category_Profit) AS Overall_Category_Profit
	FROM(
			-- Subquery from the previous step
			SELECT
				P.Product_Category,
				S.Store_ID,
				SUM(S.Units * (P.Product_Price - P.Product_Cost))
				AS Total_Category_Profit
			FROM Sales S JOIN Products P ON S.Product_ID = P.Product_ID
			GROUP BY P.Product_Category, S.Store_ID
		) AS ProductProfits
	GROUP BY ProductProfits.Product_Category;
	END
	go
	-- RUN CODE
	EXEC ssum

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 7) Total Sales units by every month
	-- Top sale for product by month
	SELECT  MONTH(s.Date) AS Month, SUM(s.Units) AS Total_sales
	FROM Sales s
	GROUP BY MONTH(s.Date)
	ORDER BY Total_sales DESC

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 8) Create the function to get product name where price of product max 10$
	CREATE FUNCTION CheckProductPrice(@ProductName NVARCHAR(255))
	RETURNS INT
	AS
	BEGIN
	DECLARE @Result INT;

	-- Check for the existence of a record in the subquery
	SET @Result = (
	SELECT TOP 1 1
	FROM Products p1
	WHERE p1.Product_Name = @ProductName
	AND EXISTS (
		-- Subquery: Selects the Product_Price from Products (p) and Sales (s) tables
		SELECT 1
		FROM Products p, Sales s
		-- Joins Products and Sales tables based on the Product_ID
		WHERE s.Product_ID = p.Product_ID
		AND p.Product_Price > 10
		AND p.Product_Name = @ProductName )
	);

	-- Return the result
	RETURN ISNULL(@Result, 0);
	END;

	-- Use the function in a query
	SELECT Product_Name
	FROM Products
	WHERE dbo.CheckProductPrice(Product_Name) = 1;

-----------------------------------------------------------
--------------------  Stores Story -----------------------
-----------------------------------------------------------

    -- 9) Show Details Total for Branches, Locations, Covered cities
	SELECT
		MIN(Store_Open_Date) AS First_Store_Open_Date,
		COUNT(DISTINCT Store_Location) AS Total_Locations,
		COUNT(DISTINCT Store_City) AS Total_Cities,
		COUNT(DISTINCT Store_Name) AS Total_Branches
	FROM Stores s

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 10) Store performance:								
	-- Which stores demonstrate the best performance in terms of total sales or units sold?								

	-- BY Total Units
	SELECT  TOP (5) SUM(S.Units) AS Total_Units_Sold, st.Store_Name as Store_Name
	FROM Stores st JOIN Sales S
	ON st.Store_ID = s.Store_ID
	GROUP BY st.Store_Name
	ORDER BY Total_Units_Sold DESC;

	-- BY Total Sales
	SELECT  TOP (5) COUNT(S.Sale_ID) AS Total_Units_Sold, st.Store_Name as Store_Name
	FROM Stores st JOIN Sales S
	ON st.Store_ID = s.Store_ID
	GROUP BY st.Store_Name
	ORDER BY Total_Units_Sold DESC;
	------------------------------------
	-- create unique index for table sales
	CREATE INDEX saleID_index
	ON Sales(Sale_ID);
	-- To Drop
	DROP INDEX Sales.Sale_ID;

	-----------------------------------------------------------
	-----------------------------------------------------------

    -- 11) Sum of Branch Store by store location and percentage 
	-- of branches from the number of store branches.
	SELECT
		Store_Location,
		COUNT(DISTINCT Store_Name) AS Total_Branches,
		CAST(COUNT(DISTINCT Store_Name) * 100.0 / SUM(COUNT(DISTINCT Store_Name)) 
		OVER () AS DECIMAL(5, 2)) AS Branch_Percentage
	FROM
		Stores
	GROUP BY
		Store_Location;
																							
	-----------------------------------------------------------
	-----------------------------------------------------------

	--12) Best and worst-performing stores or city or location:									
    --Which individual stores are performing exceptionally well or poorly, and why?
    
	-- show best stores location, city by total sales 
	SELECT Store_City, Store_Location 
	FROM (
		SELECT Store_City, Store_Location,
			   ROW_NUMBER() OVER(PARTITION BY Store_Location ORDER BY TotalSales DESC) AS Rank
		FROM (
			SELECT st.Store_City, st.Store_Location, SUM(s.Units) AS TotalSales 
			FROM Sales s 
			INNER JOIN Stores st ON s.Store_ID = st.Store_ID
			GROUP BY st.Store_City, st.Store_Location
		) CitySales
	) RankedCities
	WHERE Rank = 1

	---- mina

	SELECT st.Store_City, st.Store_Location, 
		   SUM(s.Units) AS TotalSales
	FROM Sales s INNER JOIN Stores st ON s.Store_ID = st.Store_ID
	GROUP BY st.Store_Location, st.Store_City
	order by st.Store_Location
 
-----------------------------------------------------------
--------------------  Inventory Story -----------------------
-----------------------------------------------------------

	-- 13) Calculate Total Stock on Hand, Expected Profit and Expected Revenue by Category

	-- USE Rollup
	SELECT
		CASE
			WHEN GROUPING(P.Product_Category) = 1 THEN 'Total'
			ELSE P.Product_Category
		END AS Product_Category,
		SUM(Stock_On_Hand) AS Total_Stock_On_Hand,
		SUM(I.Stock_On_Hand * (P.Product_Price - P.Product_Cost)) AS Expected_Profit,
		SUM(I.Stock_On_Hand * P.Product_Price) AS Expected_Revenue
	FROM Inventory I
	JOIN Products P ON I.Product_ID = P.Product_ID
	GROUP BY ROLLUP(P.Product_Category);

    -- USE Cube
	SELECT
		COALESCE(P.Product_Category, 'Total') AS Product_Category,
		SUM(Stock_On_Hand) AS Total_Stock_On_Hand,
		SUM(I.Stock_On_Hand * (P.Product_Price - P.Product_Cost)) AS Expected_Profit,
		SUM(I.Stock_On_Hand * P.Product_Price) AS Expected_Revenue
	FROM Inventory I
	JOIN Products P 
	ON I.Product_ID = P.Product_ID
	GROUP BY CUBE(P.Product_Category)

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 14) Stock on hand by store location

	SELECT S.Store_Location,
	SUM(I.Stock_On_Hand) AS Total_Stock_On_Hand
	FROM Inventory I
	JOIN Stores S ON I.Store_ID = S.Store_ID
	GROUP By S.Store_Location;

	-----------------------------------------------------------
	-----------------------------------------------------------

	-- 15) Total Stock on hand VS Sold Uint by Prodact category 
	SELECT
		COALESCE(P.Product_Category, 'Total') AS Product_Category,
		SUM(I.Stock_On_Hand) AS Total_Stock_On_Hand,
		SUM(S.Units) AS Total_Sold_Units
	FROM Products P
	JOIN Inventory I 
	ON P.Product_ID = I.Product_ID
	LEFT JOIN Sales S 
	ON P.Product_ID = S.Product_ID AND I.Store_ID = S.Store_ID
	GROUP BY CUBE(P.Product_Category);

	-----------------------------------------------------------
	-----------------------------------------------------------

	 -- 16) The Top 10 products based on expected revenue and expected profit.

	SELECT TOP 10 P.Product_Name,
		SUM(I.Stock_On_Hand * (P.Product_Price - P.Product_Cost)) AS Expected_Profit,
		SUM(I.Stock_On_Hand * P.Product_Price) AS Expected_Revenue
	FROM Products P
	JOIN Inventory I ON P.Product_ID = I.Product_ID
	GROUP BY P.Product_Name
	ORDER BY Expected_Revenue DESC;

	------------------------------------------
	------------------------------------------

	-- Create the trigger
	CREATE OR ALTER TRIGGER UpdateInventoryOnSale
	ON Sales
	AFTER INSERT
	AS
	BEGIN
    -- Update Inventory on sale
    -- Subtract the sold units from the Stock_On_Hand for the corresponding product and store
    UPDATE Inventory
    SET Stock_On_Hand = Stock_On_Hand - i.Units
    FROM Inventory
    INNER JOIN inserted i ON Inventory.Product_ID = i.Product_ID 
	AND Inventory.Store_ID = i.Store_ID;
    END;

	-- Drop the trigger
	DROP TRIGGER UpdateInventoryOnSale;

	------------------------------------------
	------------------------------------------

	-- Create the Cursor

	-- Declare variables
	DECLARE @ProductID INT, @ProductCost DECIMAL(10, 2);

	-- Declare the cursor
	DECLARE ProductCursor CURSOR FOR
	SELECT Product_ID, Product_Cost
	FROM Products
	WHERE Product_Cost > 1000;

	-- Open the cursor
	OPEN ProductCursor;

	-- Fetch the first row
	FETCH NEXT FROM ProductCursor INTO @ProductID, @ProductCost;

	-- Loop through the cursor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Apply a 10% discount
		DECLARE @DiscountedCost DECIMAL(10, 2);
		SET @DiscountedCost = @ProductCost - 0.90; -- 10% discount

		-- Update the product with the discounted cost
		UPDATE Products
		SET Product_Cost = @DiscountedCost
		WHERE Product_ID = @ProductID;

		-- Fetch the next row
		FETCH NEXT FROM ProductCursor INTO @ProductID, @ProductCost;
	END;

	-- Close and deallocate the cursor
	CLOSE ProductCursor;
	DEALLOCATE ProductCursor;

	GO

	-- Display data before the discount
	PRINT 'Products Data Before Discount:';
	SELECT * FROM Products;

	-- Apply a 10% discount to products with a cost greater than 1000
	UPDATE Products
	SET Product_Cost = Product_Cost - 0.90
	WHERE Product_Cost > 10;

	-- Display data after the discount
	PRINT 'Products Data After Discount:';
	SELECT * FROM Products;

-----------------------------------------------------------
--------------------  Sales Story -----------------------
-----------------------------------------------------------

	-- 17) Sales: Total sales by week, month, year:
	-- What are the trends in total sales when analyzed by different time periods?
	SELECT P.Product_Name,
	   -- DATEPART(WEEK, S.Date) AS WeekNumber,
	   -- DATEPART(MONTH, S.Date) AS MonthNumber,
		DATEPART(YEAR, S.Date) AS YearNumber,
		SUM(S.Units) AS 'Sum of Units'
	FROM Sales S JOIN Products P ON P.Product_ID = S.Product_ID
	GROUP BY P.Product_Name, 
		-- DATEPART(WEEK, S.Date),
		-- DATEPART(MONTH, S.Date),
			 DATEPART(YEAR, S.Date);

	-----------------------------------------------------------
	-----------------------------------------------------------

  -- END SOLVE