
select * from sales
select * from products
select * from customers
select * from city

--1.) How many people in each city are estimated to consume coffee, given that 25% of the population does?
select * from city
select city_name,
round(population*0.25/1000000,2) as coffee_consumers_in_million from city 
order by 2

--2.) What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select * from city
select * from customers
select * from sales

select c1.city_name,sum(total) as total_sales from customers as c inner join sales as s on c.customer_id = s.customer_id join city as c1 on c1.city_id=c.city_id
where extract(year from sale_date) = 2023 and extract(quarter from sale_date)=4
group by 1

--3.) How many units of each coffee product have been sold?
select * from products
select * from sales

select product_name,count(sale_id) as total_no_of_sales_of_product
from products as p inner join sales as s on p.product_id = s.product_id
group by 1
order by 2 desc

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select * from sales
select * from customers
select * from city

select customer_name,city_name,sum(total)/count(sale_id)::numeric as average_sales_per_person
from sales as s inner join customers as c on s.customer_id = c.customer_id
inner join city as c1 on c1.city_id = c.city_id
group by 1,2
order by 3 desc

------------------------------or---------------another logic
select customer_name,city_name,sum(s.total) as total_revenue,count(distinct s.customer_id) as total_customer_per_state,
sum(s.total)/count(distinct s.customer_id) as average_sales
from sales as s inner join customers as c on s.customer_id = c.customer_id inner join city as c1 on
c1.city_id = c.city_id 
group by 1,2
order by 2 desc
--------------------------------------------------------------------------
--5.) -- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

with city_table as (
select city_name, Round((population*0.25)/1000000,2) as coffee_consumers from city
),
customers_table as (
select ci.city_name as city_name,count(distinct c.customer_id) as unique_customer_id 
from sales as s inner join customers as c on c.customer_id = s.customer_id inner join
city as ci on ci.city_id = c.city_id
group by 1
)

select customers_table.city_name,city_table.coffee_consumers ,
customers_table.unique_customer_id from city_table inner join customers_table on
city_table.city_name = customers_table.city_name


--Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select * from city
select * from sales
select * from products
select * from customers

-----(My logic)
with cte as (
select c2.city_name,p.product_name, count(*) as total_orders
,DENSE_RANK() over(partition by c2.city_name order by count(s.sale_id) desc) as rank
from sales as s inner join products as p on s.product_id = p.product_id inner join customers as c1 on
c1.customer_id = s.customer_id inner join city as c2 on c2.city_id = c1.city_id
group by 1,2
--order by 3 desc
)

select city_name,product_name,total_orders,rank from cte where rank<=3


--same 6 th question another logic  
SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3
-----------------------------------------------------------------------


--7.)How many unique customers are there in each city who have purchased coffee products?

select * from sales
select * from products
select * from customers
select * from city

--My logic 
select distinct city_name,count(distinct c.customer_id) as unique_customers 
from customers as c inner join city as c1 on c.city_id = c1.city_id inner join sales as s on
s.customer_id = c.customer_id inner join products as p on p.product_id = s.product_id
--where product_name like '%Coffee%'
group by 1
order by 2 desc


--yt logic
SELECT * FROM products;
SELECT *
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id

GROUP BY 1
order by 2 desc


--------------------------------------------------------------------------------------------------

--8.)Find each city and their average sale per customer and avg rent per customer

select * from sales
select * from products
select * from customers
select * from city


with city_table as (
select city_name,sum(s.total) as total_sales,count(distinct c.customer_id) as total_customers,
sum(s.total)::numeric/count(distinct s.customer_id)::numeric as average_sales
from sales as s inner join customers as c on s.customer_id = c.customer_id inner join city as 
c1 on c1.city_id = c.city_id
group by 1 
order by 2 desc )
, -- 2nd cte table 
city_rent as (
select city_name,estimated_rent from city
)

select c2.city_name,c2.estimated_rent,c2.estimated_rent::numeric/c1.total_customers::numeric as average_rent,
c1.total_customers,c1.total_sales, c1.average_sales from city_table as c1 inner join city_rent as c2 on
c1.city_name = c2.city_name 



