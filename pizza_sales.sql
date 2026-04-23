create database pizzahut;
use pizzahut;

show tables;
create table orders (
    order_id int primary key,
    order_date date,
    order_time time);

load data local infile 'D:/Sql_DS/sql_projects/pizza_sales/orders.csv'
into table orders
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(order_id,order_date,order_time);

select * from order_details;
select * from orders;
select * from pizzas;
select * from pizza_types;

-- Basic:

-- Retrieve the total number of orders placed.
select
	count(order_id) as Total_order
from
	orders;

-- Calculate the total revenue generated from pizza sales.
select
	round(sum(od.quantity * p.price), 2) as Total_revenue
from
	order_details od
join pizzas p
on
	p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
select
	pt.name,
	p.price as Highest_price
from
	pizza_types pt
join pizzas p
on
	p.pizza_type_id = pt.pizza_type_id
order by
	highest_price desc
limit 1;

-- Identify the most common pizza size ordered.
select
	p.size,
	count(od.order_details_id) as Most_common_pizza_size
from
	pizzas p
join order_details od 
on
	od.pizza_id = p.pizza_id
group by
	p.size
order by
	most_common_pizza_size desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select
	p.pizza_type_id ,
	pt.name,
	sum(od.quantity) as Most_common_pizza_types
from
	pizzas p
join order_details od 
on
	od.pizza_id = p.pizza_id
join pizza_types pt 
on
	p.pizza_type_id = pt.pizza_type_id
group by
	p.pizza_type_id,
	pt.name
order by
	most_common_pizza_types desc
limit 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select
	pt.category,
	sum(od.quantity) as Most_common_pizza_types
from
	pizzas p
join order_details od 
on
	od.pizza_id = p.pizza_id
join pizza_types pt 
on
	p.pizza_type_id = pt.pizza_type_id
group by
	pt.category
order by
	most_common_pizza_types desc
limit 5;

-- Determine the distribution of orders by hour of the day.
select
	hour(order_time) as hour,
	count(order_id) as Total_order_by_hour
from
	orders
group by
	hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select
	category ,
	count(name) as Distribution
from
	pizza_types
group by
	category ;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select
	round(avg(quantity)) as Average_per_day_pizza
from
	(
	select
		o.order_date ,
		sum(od.quantity) as quantity
	from
		orders o
	join order_details od 
on
		o.order_id = od.order_id
	group by
		o.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select
	pt.name,
	sum(p.price * od.quantity) as Revenue
from
	pizzas p
join pizza_types pt 
on
	p.pizza_type_id = pt.pizza_type_id
join order_details od 
on
	od.pizza_id = p.pizza_id
group by
	pt.name
order by
	Revenue desc
limit 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
select
	pt.category,
	concat(round(sum(p.price * od.quantity) / 
(select
	round(sum(od.quantity * p.price), 2) as Total_revenue
from
	order_details od
join pizzas p
on
	p.pizza_id = od.pizza_id) * 100) , '%') as Revenue
from
	pizzas p
join pizza_types pt 
on
	p.pizza_type_id = pt.pizza_type_id
join order_details od 
on
	od.pizza_id = p.pizza_id
group by
	pt.category
order by
	Revenue desc;

-- Analyze the cumulative revenue generated over time.
select
	order_date ,
	sum(Revenue) over (
	order by order_date) as Cumulative_Revenue
from
	(
	select
		o.order_date,
		sum(od.quantity * p.price) as Revenue
	from
		orders o
	join order_details od 
on
		o.order_id = od.order_id
	join pizzas p  
on
		od.pizza_id = p.pizza_id
	group by
		o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select
	category,
	name,
	Ranks
from
	(
	select
		category,
		name,
		Revenue,
		rank() over(partition by category order by Revenue desc) as Ranks
	from
		(
		select
			pt.category,
			pt.name,
			round(sum(p.price * od.quantity)) as Revenue
		from
			pizzas p
		join pizza_types pt 
on
			p.pizza_type_id = pt.pizza_type_id
		join order_details od 
on
			od.pizza_id = p.pizza_id
		group by
			pt.category,
			pt.name) as most) as final_data
where
	Ranks <= 3;






