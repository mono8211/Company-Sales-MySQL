-- Exploratory Data Analysis

-- ### General Sales Analysis

-- 1. **Total Sales**: What is the total sales revenue for each store?
SELECT 
    *
FROM
    orders;

SELECT 
    *
FROM
    employee;

SELECT 
    *
FROM
    store;

SELECT 
    s.city AS Store, SUM(o.total_price) AS 'Total Sales'
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY s.city;

-- 2. **Avegare Sales by City**: What is the average of sales by city?
SELECT 
    s.city AS Store,
    ROUND(AVG(o.total_price), 2) AS Average_Sales
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY s.city
ORDER BY Average_Sales DESC;

-- 3. **Monthly Sales Trend**: What are the monthly sales trends for each store?
SELECT 
    s.city AS Store,
    MONTHNAME(o.order_date) AS Month,
    SUM(o.total_price) AS Total_Sales
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY s.city , Month
ORDER BY Store , Total_Sales DESC;

-- 4. **Top-Selling Products**: What are the top 10 best-selling products in each store?
 
 
 select Store, Product, total_units_sales, Ranking
 from(
 select
 s.city as Store, p.product_name as Product, sum(o.quantity) as total_units_sales,
 row_number() over(partition by s.city order by sum(o.quantity) desc) as Ranking
 from 
 orders o
 inner join employee e on o.employee_id = e.employee_id
 inner join store s on e.store_id = s.store_id
 inner join product p on o.product_id = p.product_id
 group by Store, Product) Ranked_Products
 Where Ranking <= 5
 Order by Store, Ranking;
 
-- 5. **Sales Growth**: How has the sales revenue grown over the past year for each store?
use company_sales;

SELECT 
    s.city,
    a.Total_ventas_2022,
    b.Total_ventas_2023,
    ROUND(((b.Total_ventas_2023 - a.Total_ventas_2022) / a.Total_ventas_2022) * 100,
            2) AS pct_sales,
    '%'
FROM
    store s
        INNER JOIN
    (SELECT 
        s.city AS City, SUM(o.total_price) AS Total_ventas_2022
    FROM
        orders o
    INNER JOIN employee e ON o.employee_id = e.employee_id
    INNER JOIN store s ON e.store_id = s.store_id
    INNER JOIN product p ON o.product_id = p.product_id
    WHERE
        o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
    GROUP BY s.city
    ORDER BY Total_ventas_2022 DESC) a ON s.city = a.City
        INNER JOIN
    (SELECT 
        s.city AS City2, SUM(o.total_price) AS Total_ventas_2023
    FROM
        orders o
    INNER JOIN employee e ON o.employee_id = e.employee_id
    INNER JOIN store s ON e.store_id = s.store_id
    INNER JOIN product p ON o.product_id = p.product_id
    WHERE
        o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY s.city
    ORDER BY Total_ventas_2023 DESC) b ON s.city = b.City2
ORDER BY pct_sales DESC;

-- 6. **Sales by Day of the Week**: Which days of the week have the highest sales in each store?

select Store, Day, total_units_sales, Ranking
from(
select
s.city as Store, o.day_name as Day, sum(o.quantity) as total_units_sales,
row_number() over(partition by s.city order by sum(o.quantity) desc) as Ranking
from 
orders o
inner join employee e on o.employee_id = e.employee_id
inner join store s on e.store_id = s.store_id
group by Store, Day) Ranked_Days
Where Ranking <= 3
Order by Store, Ranking;

-- ### Customer Analysis

-- 7. **Customer Demographics**: What are the demographics (age, gender, etc.) of customers in each store?
-- segmentation by gender
SELECT 
    s.city AS Store,
    c.gender AS Gender,
    COUNT(c.gender) AS Quantity_Gender
FROM
    orders o
        INNER JOIN
    customer c ON o.customer_id = c.customer_id
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY Store, Gender
order by Store,Gender;

-- segmentation by average age

SELECT 
    s.city AS Store,
    c.gender AS Gender,
    FLOOR(AVG(c.age)) AS Avg_Age
FROM
    orders o
        INNER JOIN
    customer c ON o.customer_id = c.customer_id
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY Store , Gender
ORDER BY Store , Gender;

-- 8. **Customer Segmentation**: How can customers be segmented based on their purchasing behavior?
use company_sales;

SELECT 
    s.city AS Store,
    o.day_name AS Day,
    SUM(o.quantity) AS total_units_sales
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY Store , Day
ORDER BY Store , total_units_sales DESC;

-- 9. **Frequent Shoppers**: Who are the top 5 most frequent shoppers in each store?
select Store, Day, total_units_sales, Ranking
from(
select
s.city as Store, c.first_name as Name, c.last_name as Last_Name,  c.count(o.customer_id) as Freq,
row_number() over(partition by s.city order by sum(o.quantity) desc) as Ranking
from 
orders o
inner join employee e on o.employee_id = e.employee_id
inner join store s on e.store_id = s.store_id
inner join customer c on o.customer_id = c.customer_id
group by Store, Day) Ranked_Days
Where Ranking <= 10
Order by Store, Ranking;

select 
Store, Name, Last_Name, Ranking
from
(select
s.city as Store, c.customer_id, c.first_name as Name, c.last_name as Last_Name,  count(o.customer_id) as Freq,
row_number() over(partition by s.city order by sum(o.quantity) desc) as Ranking
from 
orders o
inner join employee e on o.employee_id = e.employee_id
inner join store s on e.store_id = s.store_id
inner join customer c on o.customer_id = c.customer_id
group by Store, c.customer_id) Ranked
Where Ranking <= 3
Order by Store, Ranking;


-- 10. **Average Purchase Value**: What is the average purchase value per customer in each store?
SELECT 
    s.city AS Store,
    c.customer_id AS ID,
    c.last_name AS Name,
    round(AVG(o.total_price),2) AS AVG_Purchase_Value
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
        INNER JOIN
    customer c ON o.customer_id = c.customer_id
GROUP BY Store , ID
ORDER BY Store , AVG_Purchase_Value desc;

-- ### Product Analysis

-- 11. **Product Popularity**: Which products are most popular in each store?
SELECT 
    s.city AS Store,
    product_name AS Product,
    SUM(o.quantity) AS Quantity
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
        INNER JOIN
    product p ON o.product_id = p.product_id
GROUP BY Store , Product
ORDER BY Store , Quantity DESC;

-- 12. **Product Sales Trend**: How have sales trends for key products changed over time?

SELECT 
    p.product_name as Product,
    a.Total_ventas_2022 as Ventas_2022,
    b.Total_ventas_2023 as Ventas_2023,
    ROUND(((b.Total_ventas_2023 - a.Total_ventas_2022) / a.Total_ventas_2022) * 100,
            2) AS pct_sales,
    '%'
FROM
    product p
        INNER JOIN
    (SELECT 
        p.product_name AS Product, SUM(o.total_price) AS Total_ventas_2022
    FROM
        orders o
    INNER JOIN employee e ON o.employee_id = e.employee_id
    INNER JOIN store s ON e.store_id = s.store_id
    INNER JOIN product p ON o.product_id = p.product_id
    WHERE
        o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
    GROUP BY p.product_name
    ORDER BY Total_ventas_2022 DESC) a ON p.product_name = a.Product
        INNER JOIN
    (SELECT 
        p.product_name AS Product2, SUM(o.total_price) AS Total_ventas_2023
    FROM
        orders o
    INNER JOIN employee e ON o.employee_id = e.employee_id
    INNER JOIN store s ON e.store_id = s.store_id
    INNER JOIN product p ON o.product_id = p.product_id
    WHERE
        o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY p.product_name
    ORDER BY Total_ventas_2023 DESC) b ON p.product_name = b.Product2
ORDER BY pct_sales DESC;


SELECT 
    p.product_name AS Product,
    SUM(o.total_price) AS Total_ventas_2022
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
        INNER JOIN
    product p ON o.product_id = p.product_id
WHERE
    o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY p.product_name
ORDER BY Total_ventas_2022 DESC;


SELECT 
    p.product_name AS Product2,
    SUM(o.total_price) AS Total_ventas_2023
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
        INNER JOIN
    product p ON o.product_id = p.product_id
WHERE
    o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY p.product_name
ORDER BY Total_ventas_2023 DESC;



-- ### Employee Performance

-- 13. **Sales by Employee**: What are the sales figures for each employee in each store?
SELECT 
    s.city AS Store,
    e.employee_id AS ID,
    e.last_name AS Last_Name,
    SUM(o.total_price) AS Total_Sales
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY Store , ID
ORDER BY Store , total_Sales DESC;

-- 14. **Employee Sales Targets**: How often do employees meet their sales targets in each store?

SELECT 
    Store,
    ID,
    Last_Name,
    Total_Sales,
    Target,
    Level_Over_Target,
    CASE
        WHEN Level_Over_Target > 0 THEN 'Good Performance'
        WHEN Level_Over_Target = 0 THEN 'Normal Performance'
        WHEN Level_Over_Target < 0 THEN 'Bad Performance'
    END AS Performance_Sales
FROM
    (SELECT 
        s.city AS Store,
            e.employee_id AS ID,
            e.last_name AS Last_Name,
            SUM(o.total_price) AS Total_Sales,
            68000 AS 'Target',
            SUM(o.total_price) - 68000 AS Level_Over_Target
    FROM
        orders o
    INNER JOIN employee e ON o.employee_id = e.employee_id
    INNER JOIN store s ON e.store_id = s.store_id
    GROUP BY Store , ID
    ORDER BY Store , total_Sales DESC) AS x;



-- ### Store Operations

-- 15. **Store Traffic**: How does foot traffic vary between the three stores?

SELECT 
    s.city AS Store, COUNT(o.order_id) AS Traffic
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    store s ON e.store_id = s.store_id
GROUP BY 1
ORDER BY Traffic desc;

-- 16. **Sales per Square meter**: What are the sales per square meter for each store? 
use company_sales;

SELECT 
    c.city AS City,
    c.area AS 'Area/mt2',
    SUM(o.total_price) AS Sales,
    ROUND(SUM(o.total_price) / c.area, 2) AS 'Sales per Square Meter / 2023'
FROM
    orders o
        INNER JOIN
    employee e ON o.employee_id = e.employee_id
        INNER JOIN
    (SELECT 
        *, LENGTH(city) * POW(LENGTH(city), 2) AS area
    FROM
        store) c ON e.store_id = c.store_id
WHERE
    o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 1
ORDER BY 4 DESC;

SELECT 
    order_date
FROM
    orders
ORDER BY 1 DESC;
    

 
