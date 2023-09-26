
select * from walmart_store_sales

-- 1) Which year had the highest sales?

select * into #temp1
from
(select sum(weekly_sales) as total_sales, year(date) as highest_sales_year
from walmart_store_sales
group by year(date)) as t1

select highest_sales_year from #temp1 where total_sales=(select Max(total_sales) from #temp1)

-- 2) How was the weather during the year of highest sales?

with weather_sales_impact as
(select weekly_sales, Temperature, 
IIF(Temperature<=46,'Extremely Cold weather',IIF(Temperature between 46 and 59,'Cool weather',
IIF(Temperature between 59 and 77,'Normal weather',
IIF(Temperature between 78 and 86,'Warm weather','Hot weather')))) as weather_type
from walmart_store_sales
where year(date)=2011)

select count(*), weather_type
from weather_sales_impact
group by weather_type

--  Note - 
--  So, the weather during the year of highest sales was normal to cold weather 

--  Conclude whether the weather has an essential impact on sales.

with weather_sales_impact as
(select weekly_sales, Temperature, 
IIF(Temperature<=46,'Extremely Cold weather',IIF(Temperature between 46 and 59,'Cool weather',
IIF(Temperature between 59 and 77,'Normal weather',
IIF(Temperature between 78 and 86,'Warm weather','Hot weather')))) as weather_type
from walmart_store_sales)

select sum(weekly_sales) as total_sales_wrt_weather, weather_type 
from weather_sales_impact 
group by weather_type 

Total_sales_wrt_weather    Weather_type
1441082861.8125	           Cool weather
2373307748.53125	       Normal weather
518364793.546875	       Hot weather
808476426.796875	       Warm weather
1595987157.73438	       Extremely Cold weather

sales order w.r.t. weather_type
-- normal weather>extremely cold weather>cool weather>warm weather>hot weather

--   Do the sales always rise near the holiday season for all the years?

select * into #salesduringholidays
from
(select distinct year(date)as year,weekly_sales, holiday_flag, 
lead(weekly_sales,1) over (order by year(date)) as next_week_sales
from walmart_store_sales
where holiday_flag=1 ) T1


select year, COUNT(*) as count_of_increased_sales
from #salesduringholidays
where next_week_sales>Weekly_Sales
group by year


select year, COUNT(*) as count_of_decreased_sales
from #salesduringholidays
where next_week_sales<Weekly_Sales
group by year

-- so, sales do not rise always during holiday season for all the years


-- Total sales per year

with total_sales_per_year as
(select year(date) as year, sum(weekly_sales) as total_weekly_sales
from Walmart_Store_sales
group by YEAR(Date)
)

select year,total_weekly_sales as max_sales
from total_sales_per_year
where total_weekly_sales= 
(select Max(total_weekly_sales) from total_sales_per_year)

select * from 
Walmart_Store_sales



-- 