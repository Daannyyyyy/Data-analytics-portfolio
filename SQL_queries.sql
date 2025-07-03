-- Q.1
SELECT 
    employeeNumber, 
    firstName, 
    lastName
FROM 
    employees
WHERE 
    jobTitle = 'Sales Rep'
    AND reportsTo = 1102;

-- Q.1(b)
SELECT DISTINCT 
    productLine
FROM 
    products
WHERE 
    productLine LIKE '%cars';
 -- Q.2  
SELECT 
    customerNumber, 
    customerName,
    CASE 
        WHEN country IN ('USA', 'Canada') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment
FROM 
    customers;
    
 -- Q.3
 SELECT 
    productCode, 
    SUM(quantityOrdered) AS totalQuantity
FROM 
    orderdetails
GROUP BY 
    productCode
ORDER BY 
    totalQuantity DESC
LIMIT 10;

-- Q.3(b)
SELECT 
    MONTHNAME(paymentDate) AS MonthName,
    COUNT(*) AS TotalPayments
FROM 
    payments
GROUP BY 
    MONTH(paymentDate)
HAVING 
    COUNT(*) > 20
ORDER BY 
    TotalPayments DESC;
    
-- Q.4
CREATE DATABASE IF NOT EXISTS Customers_Orders;


USE Customers_Orders;


CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

-- Q.4(b)
CREATE TABLE Orders1 (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    -- Constraints
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0)
);

-- Q.5
SELECT 
    c.country, 
    COUNT(o.orderNumber) AS total_orders
FROM 
    customers c
JOIN 
    orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.country
ORDER BY 
    total_orders DESC
LIMIT 5;

-- Q.6
SELECT 
    e.FullName AS EmployeeName,
    m.FullName AS ManagerName
FROM 
    project e
LEFT JOIN 
    project m ON e.ManagerID = m.EmployeeID;
    
-- Q.7
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50)
);


ALTER TABLE facility
MODIFY COLUMN Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD COLUMN city VARCHAR(100) NOT NULL AFTER Name;


DESCRIBE facility;

-- Q.8
CREATE VIEW product_category_sales AS
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT od.orderNumber) AS number_of_orders
FROM
    productlines pl
JOIN
    products p ON pl.productLine = p.productLine
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
GROUP BY
    pl.productLine;

SELECT * FROM product_category_sales;

-- Q.9
DELIMITER //

CREATE PROCEDURE Get_country_payments (
    IN input_year INT,
    IN input_country VARCHAR(50)
)
BEGIN
    SELECT 
        input_year AS payment_year,
        input_country AS country,
        CONCAT(ROUND(SUM(p.amount) / 1000, 0), 'K') AS total_amount_k
    FROM 
        payments p
    JOIN 
        customers c ON p.customerNumber = c.customerNumber
    WHERE 
        YEAR(p.paymentDate) = input_year
        AND c.country = input_country;
END //

DELIMITER ;

CALL Get_country_payments(2003, 'France');

-- Q.10
SELECT 
    c.customerName,
    COUNT(o.orderNumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rank
FROM 
    customers c
JOIN 
    orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerName
ORDER BY 
    order_count DESC;
    
-- Q.10(b)
SELECT
    YEAR(orderDate) AS order_year,
    MONTHNAME(orderDate) AS order_month,
    COUNT(orderNumber) AS order_count,
    CONCAT(
        ROUND(
            (COUNT(orderNumber) - 
             LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate))) * 100.0 / 
             LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)), 0
        ), '%'
    ) AS YoY_change
FROM 
    orders
GROUP BY 
    YEAR(orderDate), MONTH(orderDate)
ORDER BY 
    MONTH(orderDate), YEAR(orderDate);
    
-- Q.11
SELECT 
    productLine,
    COUNT(*) AS above_avg_count
FROM 
    products
WHERE 
    buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY 
    productLine
ORDER BY 
    above_avg_count DESC;
    
-- Q.12
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

DELIMITER //

CREATE PROCEDURE InsertIntoEmp_EH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS message;
    END;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //

DELIMITER ;

CALL InsertIntoEmp_EH(1, 'John Doe', 'john@example.com');

-- Q.13
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

DELIMITER //

CREATE TRIGGER trg_before_insert_empbit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;

INSERT INTO Emp_BIT VALUES ('TestUser', 'Intern', '2020-10-05', -9);

SELECT * FROM Emp_BIT WHERE Name = 'TestUser';


