# Mexico Toy Sales

## Overview

This repository contains sales and inventory data for Maven Toys, a fictional chain of toy stores in Mexico. The dataset includes information about products, stores, daily transactions, and current inventory levels at each location.

## Files

- **Mexico_Toy_Sales.sql**: SQL script containing database schema creation, data insertion, and various analytical queries.

## Data Details

The dataset is structured with multiple tables, and the main focus is on sales and inventory information. The key tables include:

- **Products**: Information about the toy products, including Product_ID, Product_Name, Product_Category, Product_Cost, and Product_Price.

- **Sales**: Daily transaction data, including Sale_ID, Product_ID, Store_ID, Date, and Units.

- **Stores**: Details about store locations, including Store_ID, Store_Name, Store_Location, Store_City, and Store_Open_Date.

- **Inventory**: Current inventory levels at each store, with columns such as Product_ID, Store_ID, and Stock_On_Hand.

## Recommended Analysis

1. **Product Profitability**: Analyze which product categories contribute the most to overall profits, and check if this varies across store locations.

2. **Seasonal Trends**: Investigate any seasonal trends or patterns in the sales data. Identify peak sales periods and explore potential factors influencing these trends.

3. **Inventory Management**: Examine if sales are affected by out-of-stock products at certain locations. Optimize inventory levels to meet customer demand.

4. **Inventory Financials**: Calculate the amount of money tied up in inventory and estimate how long it will last. Optimize inventory turnover for financial efficiency.

## SQL Script Details

The SQL script provides:

- Database schema creation (`CREATE SCHEMA`).
- Table creation and modification (`CREATE TABLE`, `ALTER TABLE`).
- Analytical queries for various insights:
  - Total units sold, average price, and total product sales.
  - Top-selling products.
  - Profitability analysis.
  - Geographic analysis.
  - Average margin by product and month.
  - Product filtering and aggregation queries.
  - Store performance analysis.
  - Inventory-related queries.

## How to Use

1. Execute the SQL script (`Mexico_Toy_Sales.sql`) on your SQL Server.
2. Explore the data and run analytical queries to gain insights into Maven Toys' sales and inventory.

**Happy Analyzing!**
