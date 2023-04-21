USE Northwind

SELECT * INTO Customers2 FROM Customers

INSERT INTO Customers2
SELECT * FROM Customers2
GO 3

SELECT * FROM Customers2

SELECT * INTO Orders2 FROM Orders

INSERT INTO Orders2
SELECT * FROM Orders2
GO 3


ALTER PROCEDURE CustomersCountry @Country varchar(20) = 'Germany'
AS
SELECT * FROM Customers2 WHERE Country = @Country
ORDER BY CompanyName, City

ALTER PROCEDURE CustomersCity @City varchar(20) = 'Paris'
AS
SELECT * FROM Customers2 WHERE City = @City
ORDER BY CompanyName, City

ALTER PROCEDURE CustomerOrder @CustomerID varchar(5) = 'ALFKI'
AS
SELECT * FROM Customers2 c
JOIN Orders o ON c.CustomerID = o.OrderID
WHERE o.CustomerID = @CustomerID

ALTER PROCEDURE Random WITH RECOMPILE
AS
SET NOCOUNT ON
DECLARE @ID int
SELECT @ID = 
CAST(RAND() * 100000 AS INT)
IF @ID % 5 = 0
	EXEC CustomerOrder
ELSE IF @ID % 4 = 0
	EXEC CustomersCity
ELSE 
	EXEC CustomersCountry


EXEC Random 
GO 100

SET STATISTICS TIME,IO ON
EXEC CustomersCountry

--8 Cores:
--, CPU-Zeit = 425 ms, verstrichene Zeit = 957 ms.
--Anzahl von Überprüfungen: 9, logische Lesevorgänge: 12161,

--4Cores:
-- Anzahl von Überprüfungen: 5, logische Lesevorgänge: 12161,
-- CPU-Zeit = 375 ms, verstrichene Zeit = 945 ms.

--1 Core:
-- Anzahl von Überprüfungen: 1, logische Lesevorgänge: 12161,
-- , CPU-Zeit = 297 ms, verstrichene Zeit = 1094 ms.

