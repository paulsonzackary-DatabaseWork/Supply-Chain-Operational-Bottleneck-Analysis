DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS superstore_raw;

CREATE TABLE superstore_raw (
    Shipment_ID VARCHAR(30),
    Shipment_Date DATE,
    Delivery_Date DATE,
    Weight_kg NUMERIC(10,2),
    Cost NUMERIC(10,2),
    Status VARCHAR(30),
    Distance_miles NUMERIC(10,2),
    Transit_Days INT,
    Calculated_Transit_Days INT,
    Missing_Delivery_Date BOOLEAN,
    Missing_Cost BOOLEAN,
    Invalid_Transit_Date BOOLEAN,
    Transit_Days_Calculated INT,
    Origin_Warehouse VARCHAR(50),
    Destination VARCHAR(50),
    Carrier VARCHAR(50)
);

CREATE TABLE customers(
	Customer_ID VARCHAR(8) PRIMARY KEY,
	Customer_Name VARCHAR(50),
	Segment VARCHAR(30),
	Country_Region VARCHAR(30),
	City VARCHAR(50),
	State_Province VARCHAR(30),
	Postal_Code VARCHAR(10)
);

CREATE TABLE products(
	Product_ID VARCHAR(16) PRIMARY KEY,
	Category VARCHAR(30),
	Sub_Category VARCHAR(15),
	Product_Name TEXT
);

CREATE TABLE orders(
    Order_ID VARCHAR(30),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(20),
    Customer_ID VARCHAR(8),
    Product_ID VARCHAR(16),
    Sales NUMERIC(10,2),
    Quantity INT,
    Discount FLOAT,
    Profit NUMERIC(10,2),

    PRIMARY KEY (Order_ID, Product_ID),

    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES products(Product_ID)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

