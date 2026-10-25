# Retail Sales Analysis

## Project Overview

This project focuses on analyzing sales data from a fictional electronics retail company. The analysis aims to answer key business questions about sales performance, compare results across stores, identify the best-selling products, and explore different customer segments.

The dataset contains information about sales transactions, products, customers, stores, and currency exchange rates. The original data was obtained from Maven Analytics. I also extended the dataset by creating an additional employee table representing the store workforce and management hierarchy.

## Tools & Technologies

- **Microsoft Excel** — initial data inspection
- **Power Query** — data cleaning and transformation
- **PostgreSQL** — relational database and SQL analysis
- **pgAdmin 4** — database management and query execution

## Project Workflow

1. **Data Acquisition** — obtaining the original dataset from Maven Analytics.
2. **Initial Data Inspection and Cleaning** — reviewing and cleaning the data using Power Query.
3. **Data Modeling and Preparation** — transforming the data and preparing it for database import.
4. **Database Creation** — designing and creating tables, primary keys, foreign keys, and relationships.
5. **Data Import** — loading the prepared data into PostgreSQL.
6. **Employee Data Generation** — generating synthetic employee records for individual stores and establishing reporting relationships between employees and their managers.
7. **SQL Analysis** — developing and executing SQL queries to investigate sales performance and solve analytical problems.

## Database Structure

The database includes the following tables:

- `fact_sales` — sales transactions and order line items
- `dim_customers` — customer information
- `dim_products` — product details and categories
- `dim_stores` — store information
- `dim_exchange_rates` — currency exchange rates
- `dim_employees` — employee information and management hierarchy

The database follows a dimensional modeling approach, with a central sales fact table connected to supporting dimension tables.

The additional `dim_employees` table also enables recursive SQL queries for exploring employee reporting structures.

## Repository Structure

- `SQL/01_raw_data/` — original CSV files obtained from Maven Analytics.
- `SQL/02_data_preparation/` — data prepared in Power Query for database import, SQL scripts for creating tables and relationships, and screenshots documenting the data preparation process.
- `SQL/03_analysis/` — SQL queries developed for sales analysis and additional analytical challenges.

## SQL Topics

The project will cover a range of SQL techniques, including:

- Data filtering, aggregation, and sorting
- Joins and subqueries
- Window functions
- Gaps and islands problems
- Histograms and data distributions
- Recursive queries and employee hierarchies
- Business-oriented sales analysis

## Key Findings

*This section will be completed after the analysis is finished and the main findings have been identified.*

## Project Status

The database structure and data preparation process are being developed, followed by data validation and SQL analysis. The repository will be updated as new analyses are completed.
