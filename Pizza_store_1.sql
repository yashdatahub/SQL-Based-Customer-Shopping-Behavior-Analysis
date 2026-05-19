create database pizza_store; 
-- create database as pizza store

use pizza_store; 
-- use the database

##ORDERS
create table orders(
order_id int primary key,
date DATE,
time TIME
);


## pizza_types
create table pizza_types(
pizza_type_id varchar(100) primary key,
name varchar(255),
category varchar(100),
ingredients text
);


## pizzas
create table pizza(
pizza_id varchar(20) primary key,
pizza_type_id varchar(200),
size varchar(50),
price decimal(10,2),
foreign key (pizza_type_id) references pizza_types(pizza_type_id)
on delete cascade
on update cascade
);

## order_details
create table order_details(
order_details_id int primary key,
order_id int,
pizza_id varchar(20),
quantity int,
foreign key (pizza_id) references pizza(pizza_id)
on delete cascade
on update cascade,

foreign key (order_id) references orders(order_id)
on delete cascade
on update cascade
);

select * from order_details; --
select * from orders; -- 
select * from pizza; --
select * from pizza_types; --




DESC orders;
DESC pizza;
DESC order_details;
DESC pizza_types;

alter table pizza_types modify column pizza_type_id varchar(200);


-- ************************************************************************************************************************--
/*
## Assignments Tasks
*/
call orders;
call pizza;
call pizza_types;
call order_details;

desc pizza;

-- 1. Retrieve the total number of orders placed.

select 
count(order_id) as total_order 
from orders;

-- ------------------------------------------------------------------------------------------------------------

-- 2. Calculate the total revenue generated from pizza sales.

select
sum(od.quantity * p.price) as total_revenue
from order_details as od
join pizza as p
ON od.pizza_id = p.pizza_id;
    
-- ------------------------------------------------------------------------------------------------------------

-- 3. Identify the highest-priced pizza.

select pizza_id, price
from pizza
order by price desc
limit 1 ;

SELECT pt.name, p.price
FROM pizza p
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
WHERE p.price = (
    SELECT MAX(price) 
    FROM pizza
);

-- ------------------------------------------------------------------------------------------------------------

-- 4. Identify the most common pizza size ordered.

SELECT p.size, COUNT(od.pizza_id) AS total_orders
FROM order_details od
JOIN pizza p 
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC
LIMIT 1;

-- ------------------------------------------------------------------------------------------------------------
-- 5. List the top 5 most ordered pizza types along with their quantities.

select pt.name ,sum(o.quantity) as total_order
from pizza as p
inner join order_details as o
	on p.pizza_id = o.pizza_id
join pizza_types as pt
	on pt.pizza_type_id = p.pizza_type_id
    group by pt.name
    order by total_order desc
    limit 5;

-- ------------------------------------------------------------------------------------------------------------

-- 6.Find the total quantity of each pizza category ordered.

select pt.category, sum(od.quantity)as total_quantity
from order_details as od
join pizza as p on p.pizza_id = od.pizza_id
join pizza_types as pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category
order by total_quantity desc ;

-- ------------------------------------------------------------------------------------------------------------

-- 7. Determine the distribution of orders by hour of the day.

select 
hour(time) as order_hour ,
count(order_id) as total_order
from orders
group by order_hour
order by total_order desc;

-- ------------------------------------------------------------------------------------------------------------

-- 8. Find the category-wise distribution of pizzas (count of pizza types per category).

select category,
count(name) as count_of_pizza
from pizza_types
group by category
order by count_of_pizza;

-- ------------------------------------------------------------------------------------------------------------
-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select  avg(daily_total) as avg_order
	from (
    select
    o.date, sum(od.quantity) as daily_total
from orders as o
join order_details as od
on o.order_id = od.order_id
group by date) as t;

-- ------------------------------------------------------------------------------------------------------------

-- 10. Determine the top 3 most ordered pizza types based on revenue.

select pt.pizza_type_id,pt.name,
	round(sum(p.price*od.quantity),2)as total_revenue
from pizza_types as pt
join pizza as p 
	on p.pizza_type_id = pt.pizza_type_id
join order_details as od 
	on od.pizza_id = p.pizza_id 
group by 
	pt.pizza_type_id,
    pt.name
order by total_revenue desc
limit 3;

-- ------------------------------------------------------------------------------------------------------------

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select pt.pizza_type_id, pt.name, sum(p.price * od.quantity) as each_pizza_revenue,
  ROUND(
        (SUM(p.price * od.quantity) / 
        (SELECT SUM(p2.price * od2.quantity)
         FROM order_details od2
         JOIN pizza p2 ON p2.pizza_id = od2.pizza_id)
        ) * 100, 
    2) AS revenue_percentage
from order_details as od
join pizza as p 
	on p.pizza_id = od.pizza_id
join pizza_types as pt 
	on p. pizza_type_id = pt.pizza_type_id
    group by
			pt.pizza_type_id, 
            pt.name
	order by each_pizza_revenue desc;

-- ------------------------------------------------------------------------------------------------------------

-- 12. Analyze the cumulative revenue generated over time.

with cte_1 as( select o.date, sum(p.price*od.quantity)as daily_total_revenue
from orders as o
join order_details as od
	on od.order_id = o.order_id
join pizza as p
	on od.pizza_id = p.pizza_id
join pizza_types as pt
	 on  p.pizza_type_id = pt.pizza_type_id
group by o.date
)
select date, daily_total_revenue,sum(daily_total_revenue)
	over (order by date) as cumulative_revenue
from cte_1
order by date;

-- ------------------------------------------------------------------------------------------------------------

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza

SELECT pt.pizza_type_id,
       pt.name,
       ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM pizza_types AS pt
JOIN pizza AS p 
    ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
    ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_type_id, pt.name
ORDER BY total_revenue DESC
LIMIT 3;



-- 14. Find orders where multiple pizzas were ordered but all pizzas are from the same category.

SELECT 
    od.order_id,
    MAX(pt.category) AS category
FROM order_details AS od
JOIN pizza AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY od.order_id
HAVING 
    SUM(od.quantity) > 1
    AND COUNT(DISTINCT pt.category) = 1;


select * from pizza;
select * from orders;
select * from order_details;
select * from pizza_types;



-- 15. Find the ingredient that contributes the most to revenue.

SELECT pt.ingredients,
       ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM pizza_types AS pt
JOIN pizza AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.ingredients
ORDER BY total_revenue DESC
LIMIT 1;