# homeService
This project covers planning and creating a relational database in PostgreSQL for an online service system

## 1. Data-modeling

The first step is to design an ER diagram to show entity and its relationships.
![Home Services ERD](https://github.com/SkywalkerZ/homeService/assets/6307592/8739cfe6-c827-4ff6-a29e-d7f4f0c5b357)

### Idealogy
1. Customer Table: Contains attributes to adequately capture customer information. There is a 1-n relationship between customer and orders table and a 1-1 relationship between customer and customer_loyalty table. Meaning, each customer can have multiple orders (and not be placed at once, explained later.) but there can only be one customer associated to an order. Also, each customer can be enrolled once in a points program to reward their loyalty.
2. Employee Table: Contains attributes to adequately capture employee information. There is a 1-n relationship between customer and orders table. Meaning, each employee can have multiple orders but there can only be one employee associated to an order.
3. Rating Table: Contains attributes to adequately describe a rating. Done to prevent vertical replication of text.
4. Status Table: Contains attributes to adequately describe a status. Done to prevent vertical replication of text.
5. Order Type Table: Contains attributes to adequately describe an order type. Done to prevent vertical replication of text and numbers.
6. Orders Table: Contains attributes to adequately describe an order. There is a 1-n relationship between itself and 2 other tables (Customer & Employee). There is a 1-1 relationship between orders and order type table. Meaning, each order can only be of one such type. There is a 1-1 relationship between orders and rating. Meaning, each order can only be one rating submitted per order. There is a 1-1 relationship between orders and status. Meaning, there can only be one status assigned at any given point to an order.
7. Customer Loyalty Table: Contains attributes to adequately describe a customers loyalty over time. There is a 1-1 relationship between customer and customer_loyalty table.

### Data Types
1. Each data type is thoroughly thought after to reduce unnecessary storage space.
2. Each data type enforces a strict set of rules to be followed.

## 2. Schema-modeling

The second step is to create the schema w.r.t the above ERD diagram. Here we specify constraints to inforce certain logic in our database.

### Code
```
CREATE TABLE Customer (
    customer_id serial PRIMARY KEY
    first_name varchar(20)   NOT NULL,
    last_name varchar(20)   NOT NULL,
    email_id varchar(50)   NOT NULL,
    phone_no varchar(15)   NOT NULL,
    address1 varchar(50)   NOT NULL,
    address2 varchar(50)   NULL,
    state varchar(20)   NOT NULL,
    pin_code varchar(10)   NOT NULL,
    customer_rating real   NOT NULL,
    last_login timestamp   NOT NULL,
    created_at timestamp   NOT NULL,
    updated_at timestamp   NOT NULL,
	UNIQUE(email_id,phone_no)
);


CREATE TABLE Rating (
    rating_id serial   NOT NULL PRIMARY KEY,
    rating_desc varchar(10)   NOT NULL UNIQUE
);

CREATE TABLE Status (
    status_id serial   NOT NULL PRIMARY KEY,
    status varchar(10)   NOT NULL UNIQUE
);

CREATE TABLE Employee (
    employee_id serial   NOT NULL PRIMARY KEY,
    first_name varchar(20)   NOT NULL,
    last_name varchar(20)   NOT NULL,
    govt_id varchar(20)   NOT NULL UNIQUE,
    phone_no varchar(15)   NOT NULL UNIQUE,
    employee_rating real   NOT NULL,
    created_at timestamp   NOT NULL,
    updated_at timestamp   NOT NULL
);

CREATE TABLE Order_Type (
    orderType_id serial   NOT NULL PRIMARY KEY,
    orderType_desc text   NOT NULL,
    orderType_price integer   NOT NULL
);

CREATE TABLE Orders (
    order_id serial   NOT NULL PRIMARY KEY,
    customer_id int   NOT NULL,
    order_type int   NOT NULL,
    employee_id int   NOT NULL,
    feedback smallint   NOT NULL,
    status smallint   NOT NULL,
    created_at timestamp   NOT NULL,
    updated_at timestamp   NOT NULL,
	UNIQUE (order_id, customer_id, status),
	CONSTRAINT fk_Order_customer_id FOREIGN KEY (customer_id) REFERENCES Customer (customer_id) ON DELETE CASCADE,
	CONSTRAINT fk_Order_order_type FOREIGN KEY (order_type) REFERENCES Order_Type (orderType_id) ON DELETE SET NULL,
	CONSTRAINT fk_Order_employee_id FOREIGN KEY (employee_id) REFERENCES Employee (employee_id) ON DELETE SET NULL,
	CONSTRAINT fk_Order_feedback FOREIGN KEY (feedback) REFERENCES Rating (rating_id) ON DELETE SET NULL,
	CONSTRAINT fk_Order_status FOREIGN KEY (status) REFERENCES Status (status_id) ON DELETE SET NULL
);

CREATE TABLE Customer_Loyalty (
    row_id serial   NOT NULL PRIMARY KEY,
    customer_id int   NOT NULL,
    orders_placed int   NOT NULL,
    money_spent int   NOT NULL,
    points int   NOT NULL,
	CONSTRAINT fk_Customer_Loyalty_customer_id FOREIGN KEY (customer_id) REFERENCES Customer (customer_id) ON DELETE CASCADE
);
```

### Constraints
- Each constraint is set to inforce a rule to align with business logic. For example:
   1. In orders table, there is a unique constraint set on 2 columns to allow 1 order per customer is allowed to be in an active state.
   2. Once a customer deletes their profile, for data protection and privacy, all their order history and loyalty points are deleted.
  
## 3. Data Insertion
Using chatgpt, I created mock data and ingested it into tables using python.

### Data
The data files (.csv) can  be found in the repository.

### Code
```
import psycopg2
conn = psycopg2.connect(
    host='localhost',
    dbname= 'HomeServices',
    user='postgres',
    password='1234567',
    port='5432'
)

cursor = conn.cursor()

import os
import pandas as pd

df = pd.read_csv(r"C:\xyz\customer.csv")
for row in df.itertuples():
    cursor.execute("INSERT INTO public.customer(first_name,last_name,email_id,phone_no,address1,address2,state,pin_code,customer_rating,last_login,created_at,updated_at) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                              (row.first_name,
                              row.last_name,
                              row.email_id,
                              row.phone_no,
                              row.address1,
                              row.address2,
                              row.state,
                              row.pin_code,
                              row.customer_rating,
                              row.last_login,
                              row.created_at,
                              row.updated_at))
conn.commit()

df = pd.read_csv(r"C:\xyz\employee.csv")
for row in df.itertuples():
    cursor.execute("INSERT INTO public.employee(first_name,last_name,govt_id,phone_no,employee_rating,created_at,updated_at) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                              (row.first_name,
                              row.last_name,
                              row.govt_id,
                              row.phone_no,
                              row.employee_rating,
                              row.created_at,
                              row.updated_at))
conn.commit()

df = pd.read_csv(r"C:\xyz\ordertype.csv")
for row in df.itertuples():
    cursor.execute("INSERT INTO public.order_Type(orderType_desc,orderType_price) VALUES (%s,%s)",
                              (row.orderType_desc,
                              row.orderType_price))
conn.commit()

df = pd.read_csv(r"C:\xyz\rating.csv")
for row in df.itertuples():
    cursor.execute(f"INSERT INTO public.rating(rating_desc) VALUES ('{row.rating_desc}')")
conn.commit()

df = pd.read_csv(r"C:\xyz\status.csv")
for row in df.itertuples():
    cursor.execute(f"INSERT INTO public.status(status) VALUES ('{row.status}')")
conn.commit()

df = pd.read_csv(r"C:\xyz\orders.csv")
for row in df.itertuples():
    cursor.execute("INSERT INTO public.orders(customer_id,order_type,employee_id,feedback,status,created_at,updated_at) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                              (row.customer_id,
                              row.order_type,
                              row.employee_id,
                              row.feedback,
                              row.status,
                              row.created_at,
                              row.updated_at))
conn.commit()

cursor.close()
conn.close()

```

### Stored Procedure

The table customer_loyalty should populate based on their order history, and points will be awareded based on that.
The points calculation is as follows:
1. For customers with total orders below 20 get 15% of total money spent as reward points.
2. For customer with total orders below 50 get 20% of total money spent as reward points.
3. For customer with total orders above 100 get 25% of total money spent as reward points.

The following stored procedure populates all the columns:

```
CREATE OR REPLACE PROCEDURE calculate_customer_loyalty()
LANGUAGE plpgsql
AS $$
DECLARE
    customer_row RECORD;
	pointer INTEGER;
    total_orders INTEGER;
    total_money_spent INTEGER;
    reward_points INTEGER;
BEGIN
    -- Loop through each customer
	pointer = 1;
	DELETE FROM customer_loyalty;
    FOR customer_row IN SELECT customer_id FROM Customer LOOP
        -- Calculate total orders placed by the customer
        SELECT COUNT(order_id) INTO total_orders FROM Orders WHERE customer_id = customer_row.customer_id;

        -- Calculate total money spent by the customer
        SELECT SUM(orderType_price) INTO total_money_spent FROM Orders
        INNER JOIN Order_Type ON Orders.order_type = Order_Type.orderType_id
        WHERE customer_id = customer_row.customer_id;

        -- Calculate reward points based on total orders and money spent
        IF total_orders < 20 THEN
            reward_points := total_money_spent * 0.15;
        ELSIF total_orders < 50 THEN
            reward_points := total_money_spent * 0.20;
        ELSE
            reward_points := total_money_spent * 0.25;
        END IF;

        -- Insert or update loyalty information for the customer
        INSERT INTO Customer_Loyalty (row_id, customer_id, orders_placed, money_spent, points)
        VALUES (pointer,customer_row.customer_id, total_orders, total_money_spent, reward_points);
		pointer = pointer +1;
    END LOOP;
END;
$$

CALL calculate_customer_loyalty();
```

### Screenshots

1. Customer Table:
   
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/507dcf25-e719-474d-9c46-29f10713e8ce)

3. Employee Table:
   
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/05c46101-aa41-472d-bb08-54bb3b613c0d)

5. Order Type Table:
   
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/fb31c455-691f-460d-8da2-43ede3a370f9)

7. Rating Table:
   
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/0d24ea2d-bf86-4e3d-8dd8-d478540948f1)

9. Status Table:
    
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/11836010-1904-4587-8ba1-91858768ceb5)

11. Orders Table:
    
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/6b907edb-912f-44ae-80fa-4d3217e62baa)

13. Loyalty Table:
    
	![image](https://github.com/SkywalkerZ/homeService/assets/6307592/f89e04d0-3178-469b-b94d-4ca2e7101bfe)

## Schema Updates

Turns out, customer_loyalty table has no date columns. Lets fix that. To do so, we need to ALTER and UPDATE the table.

```
ALTER TABLE customer_loyalty ADD COLUMN created_at TIMESTAMP;
UPDATE customer_loyalty SET created_at = NOW() WHERE created_at IS NULL RETURNING *;
```

![image](https://github.com/SkywalkerZ/homeService/assets/6307592/53f8a0b2-5928-4419-a3f3-3e336ef00662)

Lets also modify the stored procedure to include the new column as well as only consider orders with status 'completed':

```
CREATE OR REPLACE PROCEDURE calculate_customer_loyalty()
LANGUAGE plpgsql
AS $$
DECLARE
    customer_row RECORD;
    total_orders INTEGER;
    total_money_spent INTEGER;
    reward_points INTEGER;
BEGIN
    -- Loop through each customer
    FOR customer_row IN SELECT customer_id FROM Customer LOOP
        -- Calculate total orders placed by the customer with status 3
        SELECT COUNT(order_id) INTO total_orders FROM Orders WHERE customer_id = customer_row.customer_id AND status = 3;

        -- Calculate total money spent by the customer on orders with status 3
        SELECT COALESCE(SUM(orderType_price), 0) INTO total_money_spent FROM Orders
        INNER JOIN Order_Type ON Orders.order_type = Order_Type.orderType_id
        WHERE customer_id = customer_row.customer_id AND status = 3;

        -- Calculate reward points based on total orders and money spent
        IF total_orders < 20 THEN
            reward_points := total_money_spent * 0.15;
        ELSIF total_orders < 50 THEN
            reward_points := total_money_spent * 0.20;
        ELSE
            reward_points := total_money_spent * 0.25;
        END IF;

        -- Insert or update loyalty information for the customer
        INSERT INTO Customer_Loyalty (customer_id, orders_placed, money_spent, points, created_at)
        VALUES (customer_row.customer_id, total_orders, total_money_spent, reward_points, NOW())
        ON CONFLICT (customer_id) DO UPDATE
        SET orders_placed = EXCLUDED.orders_placed, money_spent = EXCLUDED.money_spent, points = EXCLUDED.points;
    END LOOP;
END;
$$;

CALL calculate_customer_loyalty();
```

![image](https://github.com/SkywalkerZ/homeService/assets/6307592/8cbb08a6-71d4-4026-9578-bfce914e1dac)


## Implement Business Logic

1. If order is more than 1 day old, and if status is 1 (or Pending), move it to 2 (or Confirmed), if not done so.
2. If order status is 2 (or Confirmed) and has stayed in that status for 7 days, move it to 3 (or Completed), if not done so.
3. Once order is completed and feedback submitted, refresh employee's rating.

To implement the above logic, we need to use functions and procedures.

```
CREATE OR REPLACE PROCEDURE pr_update_order_status()
AS $$
DECLARE
	order_row RECORD;
	v_status INTEGER;
	v_updated_at TIMESTAMP;
BEGIN
	FOR order_row IN SELECT order_id FROM orders LOOP
		SELECT orders.status,orders.updated_at
		INTO v_status,v_updated_at
		FROM orders WHERE orders.status IN (1,2);
		
		IF v_status = 1 AND EXTRACT('day' FROM NOW())- EXTRACT('day' FROM v_updated_at) = 1 THEN
			v_status = 2, v_updated_at = NOW();
			UPDATE orders SET status = v_status WHERE status =v_status;
			UPDATE orders SET updated_at = v_updated_at WHERE status = v_status;
		ELSIF v_status = 2 AND EXTRACT('day' FROM NOW())- EXTRACT('day' FROM v_updated_at) = 7 THEN
			v_status = 3, v_updated_at = NOW();
			UPDATE orders SET status = v_status WHERE status =v_status;
			UPDATE orders SET updated_at = v_updated_at WHERE status = v_status;
		END IF;
		
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL pr_update_order_status();
```





