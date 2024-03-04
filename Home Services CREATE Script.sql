CREATE TABLE Customer (
    customer_id serial PRIMARY KEY,
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
	UNIQUE (customer_id, status),
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




