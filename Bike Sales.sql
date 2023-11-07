USE [BikeStores]
GO

-- Create a calender lookup table to get better insights with detailed dates 
CREATE TABLE [BikeStores].[dbo].[CalenderLookUp] (
	[Date] DATE,
	day_of_week_number INT,
	day_of_week_name VARCHAR(75),
	day_of_month_number INT,
	month_number INT,
	year_number INT,
	weekend_flag INT,
	holiday_flag INT
)
GO

-- Automate the first column of the look up table, in this case the "Date" column 
WITH Dates AS (
	SELECT CAST('01-01-2011' AS DATE) AS DateValues

	UNION ALL

	SELECT DATEADD(DAY, 1, DateValues)
	FROM Dates
	WHERE DateValues < '12-31-2018'
)
INSERT INTO [BikeStores].[dbo].[CalenderLookUp] (Date)
SELECT * FROM Dates OPTION(MAXRECURSION 10000)

SELECT * FROM [BikeStores].[dbo].[CalenderLookUp]


-- Populate each column from the data inside of the "Date"
UPDATE [BikeStores].[dbo].[CalenderLookUp]
SET day_of_week_number = DATEPART(DAY, Date),
    day_of_week_name = FORMAT(Date, 'dddd'),
    day_of_month_number = DAY(Date),
    month_number = MONTH(Date),
    year_number = YEAR(Date)

-- Check the results
SELECT * FROM [BikeStores].[dbo].[CalenderLookUp]


-- Populate information into the weekend_flag column to indicate if the day is a weekend or not
UPDATE [BikeStores].[dbo].[CalenderLookUp]
SET weekend_flag = CASE WHEN day_of_week_name IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END

SELECT * FROM [BikeStores].[dbo].[CalenderLookUp]


-- Populate information into the holiday_flag column to indicate if the day is a holiday or not
UPDATE [BikeStores].[dbo].[CalenderLookUp]
SET holiday_flag = CASE WHEN MONTH(Date) = 1 AND DAY(Date) = 1 THEN 1 
			WHEN MONTH(Date) = 1 AND DAY(Date) = 3 THEN 1
			WHEN MONTH(Date) = 2 AND DAY(Date) = 3 THEN 1
			WHEN MONTH(Date) = 5 AND DAY(Date) = 27 THEN 1
			WHEN MONTH(Date) = 6 AND DAY(Date) = 19 THEN 1
			WHEN MONTH(Date) = 7 AND DAY(Date) = 4 THEN 1
			WHEN MONTH(Date) = 9 AND DAY(Date) = 1 THEN 1
			WHEN MONTH(Date) = 10 AND DAY(Date) = 2 THEN 1
			WHEN MONTH(Date) = 11 AND DAY(Date) = 11 THEN 1
			WHEN MONTH(Date) = 11 AND DAY(Date) = 4 THEN 1
			WHEN MONTH(Date) = 12 AND DAY(Date) = 25 THEN 1
			ELSE 0 
		   END


-- Check the results
SELECT * FROM [BikeStores].[dbo].[CalenderLookUp]


-- 
select * from production.brands
select * from production.categories
select * from production.products
select * from production.stocks

-- 
select * from sales.customers
select * from sales.orders
select * from sales.order_items
select * from sales.staffs
select * from sales.stores

select * from sales.customers cus
join sales.orders ord
on cus.customer_id = ord.customer_id
order by ord.order_id asc


-- 
select ord.order_id,
       customers = concat(cus.first_name, ' ', cus.last_name),
       staff_members = concat(sta.first_name, ' ', sta.last_name),
       cus.city,
       cus.state,
       sto.store_name,
       brd.brand_name,
       pro.product_name,
       cat.category_name,
       ord.order_date,
       clu.day_of_week_name,
       total_units = sum(itm.quantity),
       revenue = sum(itm.quantity * pro.list_price)
from sales.customers cus
join sales.orders ord
on cus.customer_id = ord.customer_id
join sales.order_items itm
on ord.order_id = itm.order_id
join sales.stores sto
on sto.store_id = ord.store_id
join sales.staffs sta
on ord.staff_id = sta.staff_id
join production.products pro
on itm.product_id = pro.product_id
join production.categories cat
on pro.category_id = cat.category_id
join production.brands brd
on pro.brand_id = brd.brand_id
join CalenderLookUp clu
on ord.order_date = clu.Date
group by ord.order_id,
         concat(cus.first_name, ' ', cus.last_name),
         concat(sta.first_name, ' ', sta.last_name),
         cus.city,
         cus.state,
         sto.store_name,
         brd.brand_name,
         pro.product_name,
         cat.category_name,
         ord.order_date,
         clu.day_of_week_name
