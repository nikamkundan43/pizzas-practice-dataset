-- Practice Questions on Pizzas Database

CREATE DATABASE pizzahut;
USE pizzahut;

SELECT * FROM pizzahut.pizzas;

SELECT COUNT(*)
FROM pizzas;

-- As there are more than 20,000 rows we created table first then imported data
CREATE TABLE orders (
order_id INT NOT NULL,
`date` DATE NOT NULL,
`time` TIME NOT NULL,
PRIMARY KEY(order_id)
);

CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id) 
);

-- BASIC Level
-- Q1. Retrieve the total number of orders placed.
SELECT COUNT(order_id)
FROM orders;

-- Q2. Calculate the total revenue generated from pizza sales.
(SELECT SUM(od.quantity*pz.price)
FROM
order_details od
JOIN
pizzas pz 
ON od.pizza_id = pz.pizza_id);

-- Q3. Identify the highest-priced pizza.
SELECT `name`, price
FROM 
pizzas pz
JOIN
pizza_types pt
ON pz.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered.
SELECT pz.size, COUNT(od.order_details_id) AS order_count
FROM 
	pizzas pz INNER JOIN order_details od
    ON pz.pizza_id = od.pizza_id
    GROUP BY pz.size ORDER BY order_count DESC;
    
-- Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT pt.pizza_type_id, pt.name, COUNT(order_id), SUM(quantity)
FROM 	
	pizza_types pt JOIN pizzas pz
    ON pt.pizza_type_id = pz.pizza_type_id
    
    JOIN order_details od
    ON pz.pizza_id = od.pizza_id
GROUP BY pt.pizza_type_id, pt.name ORDER BY COUNT(order_id) DESC LIMIT 5;

-- INTERMEDIATE Level
-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT  pt.category, SUM(od.quantity)
FROM
	pizza_types pt JOIN pizzas pz
    ON pt.pizza_type_id = pz.pizza_type_id
    
    JOIN order_details od
    ON pz.pizza_id = od.pizza_id
    
    GROUP BY category ORDER BY SUM(od.quantity) DESC;

-- Q.7 Determine the distribution of orders by hour of the day.
SELECT HOUR(time), COUNT(order_id)
FROM orders
GROUP BY HOUR(time);

-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(pizza_type_id)
FROM 
	pizza_types
    GROUP BY category;
    
-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(quantity) 
FROM
(SELECT `date`, SUM(quantity) AS quantity
FROM orders AS `or` JOIN order_details od
	ON or.order_id = od.order_id
    GROUP BY `date`) AS order_quantity;
    
-- Q.10 Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.pizza_type_id, pt.name,  SUM(price*quantity) AS Revenue
FROM order_details od JOIN pizzas pz
	ON od.pizza_id = pz.pizza_id
    
    JOIN pizza_types pt
    ON pz.pizza_type_id = pt.pizza_type_id
    GROUP BY pizza_type_id, pt.name ORDER BY Revenue DESC 
    LIMIT 3;
 
 -- ADVANCED Level
-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,ROUND(SUM(pz.price*od.quantity) / (SELECT SUM(price*quantity) 
FROM
pizzas pz JOIN order_details od
ON pz.pizza_id = od.pizza_id)*100, 2) AS Total_Revenue_percentage
FROM pizzas pz JOIN order_details od
	ON pz.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = pz.pizza_type_id
GROUP BY pt.category;

-- Q.12 Analyze the cumulative revenue generated over time.
SELECT  `date`, 
	ROUND(SUM(Revenue) OVER (ORDER BY `date`), 2) AS cumulative_revenue
FROM
(
SELECT `date`, ROUND(SUM(price*quantity), 2) AS Revenue
FROM pizzas pz JOIN order_details od
	ON pz.pizza_id = od.pizza_id
    
    JOIN orders `or`
    ON od.order_id = or.order_id
    GROUP BY `date`
    ) AS Total_Revenue; 
    
-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue, rank_revenue
FROM
(
SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS rank_revenue
FROM

(SELECT pt.category, pt.name, (SUM(price*quantity)) AS Revenue
FROM
order_details od JOIN pizzas pz
	ON od.pizza_id = pz.pizza_id
    
JOIN pizza_types pt
	ON pt.pizza_type_id =  pz.pizza_type_id
    
    GROUP BY pt.category, pt.name) AS Category_Revenue
    ) AS Total_Revenue
WHERE rank_revenue <= 3;

