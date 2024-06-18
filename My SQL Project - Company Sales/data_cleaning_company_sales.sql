SET SQL_SAFE_UPDATES = 0;
-- DATA CLEANING
-- Analizing Customer Table 
SELECT 
    *
FROM
    customer;
/* preliminary insights: 
rename other gender: ok
calculate age:
change column name (first_name): ok
delete null values: ok
check and delete duplicates: */

-- rename columns
ALTER TABLE customer
RENAME COLUMN firs_name TO first_name;
ALTER TABLE customer
RENAME COLUMN custmer_id TO customer_id;

-- delete null values
DELETE FROM customer 
WHERE
    customer_id IS NULL and first_name IS NULL
    and last_name IS NULL
    and email IS NULL
    and birth_date IS NULL
    and gender IS NULL;
    
-- delete values gender column
UPDATE customer 
SET 
    gender = 'Other'
WHERE
    gender NOT IN ('Male' , 'Female');

-- remove duplicates
CREATE TABLE customer_cleaned LIKE customer;
insert customer_cleaned
select *
from customer;

with duplicate_cte as 
(
SELECT 
    *,
    row_number() over(partition by first_name, last_name, email, birth_date, gender) as row_num
    
FROM
    customer_cleaned)
select *
from duplicate_cte
where row_num >1;
-- there is not duplicates

-- calculate and create age row
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    gender,
    birth_date,
    ROUND(DATEDIFF(CURDATE(), birth_date) / 365, 0) AS age
FROM
    customer;

ALTER TABLE customer
ADD COLUMN age INT;

UPDATE customer 
SET 
    age = ROUND(DATEDIFF(CURDATE(), birth_date) / 365, 0);
    
SELECT 
    *
FROM
    customer;

-- Analizing employee Table 
SELECT 
    *
FROM
    employee;
/* preliminary insights: 
calculate age:
change column name (first_name): ok
change column name (last_name): ok
change store values for each employee: ok */

-- rename columns
ALTER TABLE employee
RENAME COLUMN firs_name TO first_name,
RENAME COLUMN last_nam TO last_name;

-- change store values for some employees
SELECT 
    *
FROM
    employee
WHERE
    employee_id IN (2 , 3, 4);

UPDATE employee 
SET 
    store_id = 1
where employee_id in (2,3);

UPDATE employee 
SET 
    store_id = 2
where employee_id = 4;

-- calculate age
SELECT 
    *, ROUND(DATEDIFF(CURDATE(), birth_date) / 365, 0) AS age
FROM
    employee;

ALTER TABLE employee
ADD COLUMN age INT;

UPDATE employee 
SET 
    age = ROUND(DATEDIFF(CURDATE(), birth_date) / 365, 0);

SELECT 
    *
FROM
    employee;

-- Analizing store Table 
SELECT 
    *
FROM
    store;

CREATE TABLE store_cleaned LIKE store;
insert store_cleaned
select *
from store;

select *
from store_cleaned;

/* preliminary insights: 
all ok, non changes needed */

-- Analizing product Table 
SELECT 
    *
FROM
    product;

CREATE TABLE product_cleaned LIKE product;
insert product_cleaned
select *
from product;

select *
from product_cleaned;

/* preliminary insights: 
all ok, non changes needed */

-- Analizing orders Table 
SELECT 
    *
FROM
    orders;

CREATE TABLE orders_cleaned LIKE orders;
insert orders_cleaned
select *
from orders;

select *
from orders_cleaned;


/* preliminary insights: 
it aparently looks like all its ok, 
however its necesary verify the foreing id, 
the price of the product and the total price 
that turns out from multiply price * quantity 
then;
Order_id= ok
customer_id: ok
product_id: check
unite_price: check 
employee_id: check  */

SELECT DISTINCT
    customer_id
FROM
    orders;
SELECT DISTINCT
    product_id
FROM
    orders;
SELECT DISTINCT
    employee_id
FROM
    orders;

/* The table must to have right relation with price and the price of the product table*/
use company_sales;

select * 
from product;
select *
from orders;

SELECT 
    *,
    CASE product_id
        WHEN 1 THEN 13.28
        WHEN 2 THEN 12.23
        WHEN 3 THEN 11.22
        WHEN 4 THEN 13.62
        WHEN 5 THEN 10.15
        WHEN 6 THEN 9.20
        WHEN 7 THEN 11.08
        WHEN 8 THEN 12.97
        WHEN 9 THEN 11.20
        WHEN 10 THEN 18.77
        WHEN 11 THEN 7.58
        WHEN 12 THEN 13.31
        WHEN 13 THEN 14.72
        WHEN 14 THEN 6.17
        WHEN 15 THEN 11.95
        WHEN 16 THEN 12.08
        WHEN 17 THEN 18.89
        WHEN 18 THEN 18.43
        WHEN 19 THEN 15.56
        WHEN 20 THEN 15.17
    END AS new_price
FROM
    orders;

UPDATE orders 
SET 
    unit_price = CASE product_id
        WHEN 1 THEN 13.28
        WHEN 2 THEN 12.23
        WHEN 3 THEN 11.22
        WHEN 4 THEN 13.62
        WHEN 5 THEN 10.15
        WHEN 6 THEN 9.20
        WHEN 7 THEN 11.08
        WHEN 8 THEN 12.97
        WHEN 9 THEN 11.20
        WHEN 10 THEN 18.77
        WHEN 11 THEN 7.58
        WHEN 12 THEN 13.31
        WHEN 13 THEN 14.72
        WHEN 14 THEN 6.17
        WHEN 15 THEN 11.95
        WHEN 16 THEN 12.08
        WHEN 17 THEN 18.89
        WHEN 18 THEN 18.43
        WHEN 19 THEN 15.56
        WHEN 20 THEN 15.17
    END;

select *
from orders;

SELECT 
    quantity,
    unit_price,
    total_price,
    quantity * unit_price AS new_total
FROM
    orders;

UPDATE orders 
SET 
    total_price = quantity * unit_price;

select *
from orders;

SELECT 
    order_date, DAYNAME(order_date) AS day
FROM
    orders; 

alter table orders
add column day_name varchar(20);

UPDATE orders 
SET 
    day_name = DAYNAME(order_date);

select *
from orders;


