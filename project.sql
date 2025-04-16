-- 1. Convert Dataset to SQL Database:
--    - Defined and populated tables for menu_details and order_details using the provided dataset.

-- 2. Basic SELECT Queries:
--    - Retrieved all columns from the menu_items table.
--    - Displayed the first 5 rows from the order_details table.
select * from menu_items;
select * from order_details
limit 5 ;

-- 3. Filtering and Sorting:
--    - Selected item_name and price for items in the 'American' category, sorted by price descending.
select item_name,price 
from menu_items
where category = 'American'
order by price desc ;
-- 4. Aggregate Functions:
--    - Calculated the average price of menu items.
select round((price),2) as  average_price_of_menu_items
from menu_items;
--    - Found the total number of orders placed.
select count(*) as total_number_of_orders_placed
from order_details ;

-- 5. Joins:
--    - Retrieved item_name, order_date, and order_time by joining order_details with menu_items.
select m.item_name ,o.order_date , o.order_time
from order_details as o
join menu_items as m  -- as I exclude any missing item
on o.item_id = m.menu_item_id ;
-- 6. Subqueries:
--    - Listed item_name where price is greater than the average price of all menu items.
select item_name 
from menu_items
where price > (select avg(price)
				from menu_items) ;
-- 7. Date and Time Functions:
--    - Extracted the month from order_date and counted the number of orders per month.
select MONTH(order_date) as month ,count(*) 
from order_details 
group by month ;
-- 8. Group By and Having:
--    - Displayed categories with average price > $15, including item count in each category.
select m.category , count(*)
from order_details as o
Join menu_items as m
on o.item_id = m.menu_item_id 
group by m.category
having avg(price) > 15 ; 

-- 9. Conditional Statements:
--    - Displayed item_name and price, with a new column 'Expensive' indicating if price > $20.
select item_name , 
price , 
case
	when price > 20 then 'Yes' 
	else 'NO' END AS Expensive
 FROM menu_items   ;                            


SET SQL_SAFE_UPDATES = 0;  -- turning off safe mode to update values


-- 10. Data Modification - Update:
--     - Updated the price of the menu item with item_id = 101 to $25.

UPDATE menu_items 
SET price = 25 
WHERE menu_item_id = 101;


-- 11. Data Modification - Insert:
--     - Inserted a new record into menu_items for a dessert item.
INSERT INTO menu_items 
values('133','Pies','Egyptian','25.54') ;


-- 12. Data Modification - Delete:
--     - Deleted all records from order_details where order_id < 100.
DELETE FROM order_details 
WHERE order_id < 100  ;
-- 13. Window Functions - Rank:
--     - Ranked menu items based on price, displaying item_name and rank.
SELECT item_name,price,RANK() OVER (ORDER BY price desc) as rank_
from menu_items ;

-- 14. Window Functions - Lag and Lead:
--     - Displayed item_name and price difference from previous and next menu item.
select item_name,price,lead(price) over(order by price) - price as differance
from menu_items;

-- 15. Common Table Expressions (CTE):
--     - Created a CTE for items with price > $15, then retrieved the count of such items.
with main_cte as (
					select  item_name
                    from menu_items 
                    WHERE price > 15
	)
    select count(*) as number_of_items_above_15
    from main_cte ;

-- 16. Advanced Joins:
--     - Retrieved order_id, item_name, and price by joining orders with menu_items, including non-matching menu items.
SELECT order_id, item_name, price
FROM menu_items
LEFT JOIN order_details
ON menu_items.menu_item_id = order_details.item_id
order by order_id asc;

-- 17 pivoting day and night orders
SELECT
  COUNT(CASE WHEN order_time <= '11:59:59' THEN 1 END) AS day,
  COUNT(CASE WHEN order_time >  '11:59:59' THEN 1 END) AS night,
  COUNT(*) AS total
FROM order_details;

-- 18 most ordered item 
select item_id , count(*) as count
from order_details
group by item_id
order by count desc
limit 1 ;
-- 19. Most expensive item per category:
--     - Retrieve the most expensive item (item_name and price) in each category.

select item_name , category ,price,rankx
	from (select item_name , category ,price,rank() over(partition by category order by price) as rankx
			from menu_items ) as a 
where rankx = 1 
order by price desc;

-- 20. Percentage of orders per category:
--     - Calculate the percentage of total orders that each category represents.
select category ,count(*) , ROUND((count(*)*100/(select count(*) from order_details))) as  percentage
from order_details 
left join menu_items
on order_details.item_id = menu_items.menu_item_id
group by category ;


-- 21. Average order value:
--     - Calculate the average value of an order.
select order_id , AVG(price)
from order_details 
left join menu_items
on order_details.item_id = menu_items.menu_item_id 
group by order_id;
-- 22. Least ordered items:
--     - Find items that were ordered only once or not ordered at all.
select item_id,count(*) 
from order_details
group by item_id
having count(*) = 1 ;
-- 23. Daily order trends:
--     - Count number of orders per day.
select day(order_date) as day,month(order_date) as month ,count(*)
from order_details 
group by day,month ;
-- 24. Peak ordering hour:
--     - Extract hour from order_time and count orders per hour to find the busiest time.
select hour(order_time) as hour ,count(*) ,(count(*) *100 / (select count(*) from order_details)) as percentage2
from order_details 
group by hour 
limit 5 ;


-- 25. Category with highest average price:
--     - Find which category has the highest average item price.
select category , avg(price) as average_price
from menu_items
group by category
order by average_price desc ;


-- 26. Orders containing expensive items:
--     - Find all orders that include items with price > $20.
select distinct item_name,case when price >20 then 'yes' 
			else 'No' end as expensive_items
from menu_items      ;      
-- 27. Total sales:
--     - Calculate total sales generated from all orders.
select count(distinct order_id) as number_of_orders, round(concat(sum(price),'$')) as total_Sales
from order_details
left join menu_items
on order_details.item_id = menu_items.menu_item_id ;



-- 28. Median price of menu items:
--     - Find the median price across all items.
SELECT PRICE AS MEDIAN
FROM
	(SELECT PRICE,NTILE(2) OVER (ORDER BY PRICE) AS GROUPX
	FROM menu_items) AS T
WHERE GROUPX = 1 
order by PRICE DESC
LIMIT 1 ;
   
-- 29. Price distribution buckets:
--     - Classify items into price ranges (e.g., Low, Medium, High) using CASE.
WITH TABLE1 AS (SELECT ORDER_ID ,PRICE
FROM order_details
left join menu_items
on order_details.item_id = menu_items.menu_item_id )

SELECT COUNT(CASE WHEN PRICE <= 10 THEN 1 END) AS LOW ,
			   COUNT(CASE WHEN PRICE BETWEEN 11 AND 20 THEN 1 END) AS MEDIUM ,
			   COUNT(CASE WHEN PRICE  > 20 THEN 1 END) AS HIGH
        FROM TABLE1 ;       


-- 30. Time between consecutive orders:
--     - Calculate the time difference between each order and the previous one.
SELECT DAY,MONTH,ORDER_TIME,NEXT_ORDER,time_between_orders
FROM
	(SELECT DAY(ORDER_DATE) AS DAY,month(ORDER_DATE) AS MONTH,order_time,LEAD(order_time) OVER(partition by DAY(ORDER_DATE) ,month(ORDER_DATE)) AS next_order,
	   TIMESTAMPDIFF(MINUTE,ORDER_TIME,LEAD(order_time) OVER(partition by DAY(ORDER_DATE) ,month(ORDER_DATE))) AS time_between_orders
	FROM 
		order_details) AS T2
 WHERE time_between_orders <> 0 ;       
	 

