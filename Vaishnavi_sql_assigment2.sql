 --53.	Create a customer table having following column with suitable data type
--Cust_id  (automatically incremented primary key)
--Customer name (only characters must be there)
--Aadhar card (unique per customer)
--Mobile number (unique per customer)
--Date of birth (check if the customer is having age more than15)
--Address
--Address type code (B- business, H- HOME, O-office and should not accept any other)
--State code ( MH – Maharashtra, KA for Karnataka)

create table Customer (
    Cust_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incremented primary key
    Customer_name VARCHAR(100) NOT NULL CHECK (Customer_name NOT LIKE '%[^a-zA-Z ]%'),
    Aadhar_card CHAR(12) UNIQUE NOT NULL CHECK (Aadhar_card LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),  
    Mobile_number CHAR(10) UNIQUE NOT NULL CHECK (Mobile_number LIKE '[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'), 
    Date_of_birth DATE NOT NULL CHECK (DATEDIFF(YEAR, Date_of_birth, GETDATE()) > 15), 
    Address NVARCHAR(255) NOT NULL,
    Address_type_code CHAR(1) NOT NULL CHECK (Address_type_code IN ('B', 'H', 'O')), 
    State_code CHAR(2) NOT NULL CHECK (State_code IN ('MH', 'KA'))  
)

select * from Customer

--54.Create another table for Address type which is having
--Address type code must accept only (B,H,O)
--Address type  having the information as  (B- business, H- HOME, O-office)

-- Create AddressType table
CREATE TABLE AddressType (
    Address_type_code CHAR(1) PRIMARY KEY CHECK (Address_type_code IN ('B', 'H', 'O')),  
    Address_type_desc VARCHAR(50) NOT NULL  
);


--55.Create table state_info having columns as  
--State_id  primary unique
--State name 
--Country_code char(2)

Create Table State_info(
 State_id INT Primary Key,
 State_name Varchar(100),
 Country_code Char(2)
)


--56.Alter tables to link all tables based on suitable columns and foreign keys.

ALTER TABLE Customer 
ADD CONSTRAINT FK_Customer_AddressType FOREIGN KEY (Address_type_code) 
REFERENCES AddressType(Address_type_code);

ALTER TABLE Customer 
ADD CONSTRAINT FK_Customer_State FOREIGN KEY (State_id) 
REFERENCES State_info(State_id);





use AdventureWorks2022

--Q1.Find the average currency rate conversion from USD to Algerian Dinar and Australian Dollar
--Use USD - DZD ,USD-AUD
 select * From Sales.CountryRegionCurrency
select * From Sales.Currency
select * From Sales.CurrencyRate

select CONCAT_WS(' To ',FromCurrencyCode,ToCurrencyCode) Currency_Conversion,avg(AverageRate)
from Sales.CurrencyRate where FromCurrencyCode='USD' and ToCurrencyCode in('DZD','AUD')
group by FromCurrencyCode,ToCurrencyCode

--Q2.Find the products having offer on it and display product name ,
--safety Stock Level, Listprice, and product model id, type of discount, 
--percentage of discount, offer start date and offer end date


select * from Sales.SpecialOfferProduct
select * from Production.Product
select * From Sales.SpecialOffer

select
(select p.ProductModelID from Production.Product p where p.ProductID=sop.ProductID)as Product_ModelID,
(select p.Name from Production.Product p where p.ProductID=sop.ProductID)as Product_Name,
(select p.SafetyStockLevel from Production.Product p where p.ProductID=sop.ProductID)as Safety_Stock_Level,
(select p.ListPrice from Production.Product p where p.ProductID=sop.ProductID)as List_Price,
(select sp.DiscountPct from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Percentage_of_discount,
(select sp.Type from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Type_of_discount,
(select concat_ws('  and  ',sp.StartDate,sp.EndDate) from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Start_and_end_date
from sales.SpecialOfferProduct sop

---3.create view to display Product name and Product review
select * from Production.Product
select *from Production.ProductReview

--create view ProductReviews as
SELECT p.Name,r.Comments
FROM Production.Product p

JOIN Production.ProductReview r ON p.ProductID = r.ProductID;

SELECT * FROM ProductReviews;

--4.find out the vendor for product paint, Adjustable Race and blade
Select * from Purchasing.ProductVendor
Select *from Purchasing.Vendor
Select * from Production.Product

Select pv.BusinessEntityId,(select Name from Purchasing.Vendor pv1 where pv1.BusinessEntityID=pv.BusinessEntityID)Vendor_name,
(select Name from Production.Product p
where p.Name in('Paint') or
p.Name in('Adjustable Race') or p.Name in('Blade')
and p.ProductID=pv.ProductID)Product_Name
From Purchasing.ProductVendor pv

select pv.BusinessEntityID,
	(select v.Name 
	from Purchasing.Vendor v 
	where v.BusinessEntityID=pv.BusinessEntityID) 
	VendorName,
	(select p.Name
	from Production.Product p 
	where pv.ProductID=p.ProductID) 
	ProductName
from Purchasing.ProductVendor pv
where pv.ProductID in 
(select p.ProductID 
from  Production.Product p 
where p.Name like '%paint%' or 
	  p.Name like '%Blade%' or 
	  p.Name ='Adjustable Race')

--find product details shipped through ZY - EXPRESS
select * from Purchasing.ShipMethod
select * from Production.Product
select * from Purchasing.PurchaseOrderDetail
select * from Purchasing.PurchaseOrderHeader

select

(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
(select p.ProductNumber from Production.Product p where p.ProductID=pd.ProductID)as ProductNumber,
(select sm.ShipMethodID from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipID,
(select sm.Name from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipName
FROM Purchasing.PurchaseOrderDetail pd
JOIN Purchasing.PurchaseOrderHeader ph 
    ON pd.PurchaseOrderID = ph.PurchaseOrderID
WHERE ph.ShipMethodID = (
    SELECT s.ShipMethodID 
    FROM Purchasing.ShipMethod s 
    WHERE s.Name LIKE 'ZY - EXPRESS'
)

--Q6.)find the tax amt for products where order date and ship date are on the same day
select * from Production.Product
select * from Purchasing.PurchaseOrderHeader
select * from Purchasing.PurchaseOrderDetail

select 
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
ph.TaxAmt as Tax_Amount
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
on pd.PurchaseOrderID = ph.PurchaseOrderID
where day(ph.OrderDate)=day(ph.ShipDate)


--7)find the average days required to ship the product based on shipment type.
select* from Purchasing.ShipMethod
select* from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail


select 
    ps.Name as Shipment_Type, 
    avg(DATEDIFF(DAY, ph.OrderDate, ph.ShipDate)) as Avg_Shipping_Days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps 
    on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_Shipping_Days desc;

--8)find the name of employees working in day shift

select CONCAT_WS(' ',FirstName,LastName)as Emp_name from Person.Person
where BusinessEntityID in (select BusinessEntityID from HumanResources.EmployeeDepartmentHistory 
where ShiftID in (select ShiftID from HumanResources.Shift where Name='DAY'))

--9.based on product and product cost history find the name ,
--service provider time and average Standardcost
Select * from Production.Product
select * from Production.ProductCostHistory


select 
p.Name as Product_Name,
DATEDIFF_BIG(DAY,MIN(StartDate),MAX(EndDate)) as service_provider_time,
AVG(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name


---10.)find products with average cost more than 500
Select * from Production.Product
select * from Production.ProductCostHistory


select P.Name,Avg(pc.StandardCost)Avg_stand_cost 
from Production.ProductCostHistory pc
join Production.Product p on
pc.ProductID=p.ProductID
group by p.Name 
having avg(pc.StandardCost)>500


--11.find the employee who worked in multiple territory

select  * from Person.Person
Select * from HumanResources.Employee
select * from Sales.SalesTerritory
select * from Sales.SalesTerritoryHistory
SELECT 
    p.BusinessEntityID,
    CONCAT_WS(' ', p.FirstName, p.LastName) AS Emp_name,
    COUNT(DISTINCT sth.TerritoryID) AS TerritoryCount
from HumanResources.Employee e
join Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
join Sales.SalesTerritoryHistory sth ON e.BusinessEntityID = sth.BusinessEntityID
group by p.BusinessEntityID, p.FirstName, p.LastName
having COUNT(DISTINCT sth.TerritoryID) > 1
order by TerritoryCount DESC;

--12.)Find out the product model name, product description for culture as Arabic
select * from Production.ProductModel
select * from Production.Culture
select * from Production.ProductDescription
select * from Production.ProductModelProductDescriptionCulture

select pm.Name as Product_Model_Name,
pd.Description as Product_Description
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pdc
on pm.ProductModelID=pdc.ProductModelID
join Production.ProductDescription pd
on pd.ProductDescriptionID=pd.ProductDescriptionID
join Production.Culture pc
on pc.CultureID=pdc.CultureID
where pc.Name like 'Arabic'
group by pm.Name,pd.Description


--13.	 Find first 20 employees who joined very early in the company

select * from HumanResources.Employee

select top 20 BusinessEntityId,DATEDIFF(YEAR,HireDate,GETDATE())Old_Employee from HumanResources.Employee

--14.Find most trending product based on sales and purchase.


--15.	 display EMP name, territory name, saleslastyear salesquota and bonus
select territoryId,
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus 
from sales.SalesPerson sp

--16display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom
select TerritoryID,
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus
from sales.SalesPerson sp
WHERE sp.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE Name IN ('United Kingdom', 'Germany'))

--17.Find all employees who worked in all North America territory

select  distinct TerritoryId,
(select distinct concat(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)Emp_Name,
(select name  from Sales.SalesTerritory st where  st.TerritoryID=sp.TerritoryID) TerritoryName,
(select [Group] from Sales.SalesTerritory st1 where st1.TerritoryID=sp.TerritoryID)Group_NAme
from Sales.SalesTerritoryHistory sp WHERE sp.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE [Group] IN ('North America'))

--18.find all products in the cart
Select (select Name from Production.Product pp where pp.ProductID=si.ProductID)Prod_name,
(select ProductNumber from Production.Product pp1 where pp1.ProductID=si.ProductID)Prod_Number,
Quantity
from Sales.ShoppingCartItem si

--19.find all the products with special offer
select * from Sales.SpecialOffer
select * from Sales.SpecialOfferProduct

Select Distinct(Name) from Production.Product pp where pp.ProductID 
in(select ProductID from Sales.SpecialOfferProduct)

--20.find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008

select(select CONCAT_WS(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select CONCAT_WS(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail

from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc where cc.ExpMonth=11 and cc.ExpYear=2008)

--21.Find the employee whose payment might be revised (Hint : Employee payment history)
select * From Person.Person
select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

SELECT e.BusinessEntityID, p.FirstName, p.LastName, COUNT(eph.RateChangeDate) AS PayRevisions
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e 
ON eph.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p 
ON e.BusinessEntityID = p.BusinessEntityID

--22Find total standard cost for the active Product. (Product cost history)
select * from Production.ProductCostHistory
select * from Production.Product

select 
    pch.ProductID,
    p.Name AS ProductName,
    SUM(pch.StandardCost) OVER (PARTITION BY pch.ProductID) AS TotalStandardCost
from Production.ProductCostHistory pch
join Production.Product p ON pch.ProductID = p.ProductID
where p.DiscontinuedDate IS NULL  -- Filters only active products
order by TotalStandardCost desc

--23.Find the personal details with address and
--address type(hint: Business Entiry Address , Address, Address type)

select * from Person.BusinessEntityAddress
Select * from Person.Address
select * from Person.AddressType
select* from Person.Person

select
CONCAT_WS(' ',p.FirstName,p.LastName)as Employee_Name,
a.AddressLine1  Address,
at.Name  Address_Type
from person.person p
join Person.BusinessEntityAddress ba
on p.BusinessEntityID=ba.BusinessEntityID
join Person.Address a
on a.AddressID=ba.AddressID
join Person.AddressType at
on at.AddressTypeID=ba.AddressTypeID

--24.Find the name of employees working in group of North America territory

select TerritoryID,
(select concat(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)Emp_Name,
(select name  from Sales.SalesTerritory st where  st.TerritoryID=sp.TerritoryID) TerritoryName,
(select [Group] from Sales.SalesTerritory st1 where st1.TerritoryID=sp.TerritoryID)Group_NAme,SalesLastYear,SalesQuota
from Sales.SalesPerson sp WHERE sp.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE [Group] IN ('North America'))

--25.Find the employee whose payment is revised for more than once                                  

SELECT e.BusinessEntityID, p.FirstName, p.LastName, COUNT(eph.RateChangeDate) AS PayRevisions
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e 
ON eph.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p 
ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(eph.RateChangeDate) > 1;

--26.display the personal details of  employee whose payment is revised for more than once.

select * from Person.Address
select * from Person.Person
Select * from HumanResources.Employee

SELECT p.BusinessEntityID, p.FirstName, p.LastName, p.EmailPromotion, e.Gender, e.JobTitle, 
       eph.PayFrequency, COUNT(eph.RateChangeDate) AS PayRevisions
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e ON eph.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY p.BusinessEntityID, p.FirstName, p.LastName, p.EmailPromotion, e.Gender, e.JobTitle, eph.PayFrequency
HAVING COUNT(eph.RateChangeDate) > 1;

--27.Which shelf is having maximum quantity (product inventory)
Select * from Production.ProductInventory

select top 1  Shelf,
    SUM(Quantity) AS TotalQuantity
FROM Production.ProductInventory
group by Shelf
order by TotalQuantity desc;


--28.Which shelf is using maximum bin(product inventory)
Select * from Production.ProductInventory

select top 1  Shelf,
    max(Bin) Max_use_bin
FROM Production.ProductInventory
group by Shelf
order by Max_use_bin desc;



select top 1  Shelf,
    Count(distinct Bin) Max_use_bin
FROM Production.ProductInventory
group by Shelf
order by Max_use_bin desc;

--29.Which location is having minimum bin (product inventory)

select top 1 LocationID,
    min(Bin) min_use_bin
FROM Production.ProductInventory
group by LocationID
order by min_use_bin desc;

--30.Find out the product available in most of the locations (product inventory)
select * from Production.Product
select * from Production.ProductInventory

select top 1  pi.locationid,
     count( pi.LocationID)over(partition by p.name)Max_loaction
from Production.ProductInventory pi
join Production.Product p
on p.ProductID=pi.ProductID

select top 1
    p.Name AS ProductName,
    count(distinct pi.LocationID) AS TotalLocations
from Production.ProductInventory pi
join Production.Product p ON p.ProductID = pi.ProductID
group by p.Name
order by TotalLocations desc

--31.Which sales order is having most order qualtity.

select * from Sales.SalesOrderDetail

select top 1 SalesOrderDetailID,
     sum(OrderQty)over(order by salesorderid desc )Total_Order_qty
from Sales.SalesOrderDetail

SELECT TOP 1
    sod.SalesOrderID,
    SUM(sod.OrderQty) AS TotalOrderQuantity
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SalesOrderID
ORDER BY TotalOrderQuantity DESC;

--32.find the duration of payment revision on every interval 
--(inline view) Output must be as given format 
--## revised time – count of revised salries 
--## duration – last duration of revision 
--e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years 

select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

 SELECT p.FirstName, p.LastName, SalaryRevisions.RevisedTime, 
       DATEDIFF(YEAR, SalaryRevisions.FirstRevisionDate, SalaryRevisions.LastRevisionDate) AS Duration
FROM (
    SELECT eph.BusinessEntityID, 
           COUNT(eph.RateChangeDate)  RevisedTime, 
           MIN(eph.RateChangeDate)  FirstRevisionDate, 
           MAX(eph.RateChangeDate)  LastRevisionDate
    FROM HumanResources.EmployeePayHistory eph
    GROUP BY eph.BusinessEntityID
) AS SalaryRevisions
JOIN Person.Person p ON p.BusinessEntityID = SalaryRevisions.BusinessEntityID
ORDER BY RevisedTime DESC



--33.check if any employee from jobcandidate table is having any payment revisions 
select * from HumanResources.JobCandidate
select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

select * from HumanResources.JobCandidate j where j.BusinessEntityID
in(select BusinessEntityID from HumanResources.Employee e where e.BusinessEntityID in 
(select eph.BusinessEntityID from HumanResources.EmployeePayHistory eph group by eph.BusinessEntityID
having COUNT(eph.RateChangeDate)>0))

--34.check the department having more salary revision 
select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory
select * from HumanResources.EmployeePayHistory

SELECT   d.Name AS DepartmentName, COUNT(eph.RateChangeDate) AS TotalSalaryRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.EmployeeDepartmentHistory edh 
    on eph.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d 
    on edh.DepartmentID = d.DepartmentID
group by d.Name
order by TotalSalaryRevisions DESC;

--35.check the employee whose payment is not yet revised
select e.BusinessEntityID, concat_ws(' ',p.FirstName, p.LastName)as EmployeeName
from HumanResources.Employee e
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
where e.BusinessEntityID not in 
(select distinct BusinessEntityID from HumanResources.EmployeePayHistory);

--36.find the job title having more revised payments 

select distinct(e.JobTitle), count(eph.RateChangeDate)  TotalSalaryRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
    on eph.BusinessEntityID = e.BusinessEntityID
group by e.JobTitle
having count(eph.RateChangeDate)>1
order by TotalSalaryRevisions desc;

--37.find the employee whose payment is revised in shortest duration (inline view)

select BusinessEntityID, FirstName, LastName, min(datediff(day,StartDate, EndDate)) 
as ShortestRevisionDuration
from (
    select e.BusinessEntityID, p.FirstName, p.LastName, eph.StartDate, eph.EndDate
    from HumanResources.EmployeeDepartmentHistory eph
    join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
    join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
) as PaymentRevisions
group by  BusinessEntityID, FirstName, LastName;

--38.find the colour wise count of the product (tbl: product)
select Color, count(ProductID) ProductCount
from Production.Product
where Color is not null
group by Color
order  by ProductCount desc;

--39.find out the product who are not in position to sell (hint: check the sell start and end date)
select * from Production.Product

select  name from Production.Product
where SellStartDate is null or SellStartDate> GETDATE()
or SellEndDate is  not null or SellEndDate>GETDATE()

--40.find the class wise, style wise average standard cost

select class Class,style Style,avg(StandardCost)Avg_Cost from Production.Product where
class is not null and Style is not null
group by Class,Style 
order by Avg_Cost

--41.check colour wise standard cost 
 select * from Production.Product

 select color Color,avg(StandardCost)Color_AvgCost from Production.Product
 where color is not null 
 group by Color
 order by Color_AvgCost

 --42.find the product line wise standard cost
 select Productline Product_line,avg(StandardCost)P_Std from Production.Product
 where ProductLine is not null
 group by ProductLine
 order by P_Std

 --43.Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince)
 SELECT sp.Name AS StateName, sp.StateProvinceCode, str.TaxRate
FROM Sales.SalesTaxRate str
JOIN Person.StateProvince sp 
    ON str.StateProvinceID = sp.StateProvinceID
ORDER BY sp.Name 

--44.Find the department wise count of employees

select d.Name as DepartmentName,count(e.BusinessEntityID) as EmployeeCount
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory edh
on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=edh.DepartmentID
group by d.Name

--45.	Find the department which is having more employees

SELECT d.DepartmentID, d.Name AS DepartmentName, COUNT(e.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Employee e
JOIN HumanResources.Department d ON e.BusinessEntityID = d.DepartmentID
GROUP BY d.DepartmentID, d.Name
ORDER BY EmployeeCount DESC

--46Find the job title having more employees
Select * from HumanResources.Employee
select*from HumanResources.Department

select count(BusinessEntityID)as EmployeeCount,JobTitle from  HumanResources.Employee
group by JobTitle
order by EmployeeCount desc

--47.Check if there is mass hiring of employees on single day
select  Hiredate, count(BusinessEntityID)Employee_count  From HumanResources.Employee
group by HireDate
Having count(BusinessEntityID)>1
Order by Employee_count desc

--48Which product is purchased more? (purchase order details)

SELECT  p.ProductID, p.Name AS Product_Name, SUM(pd.OrderQty) AS TotalQuantityPurchased
FROM Purchasing.PurchaseOrderDetail pd
JOIN Production.Product p ON p.ProductID = pd.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantityPurchased DESC

--49.Find the territory wise customers count   (hint: customer)
select * from Sales.Customer
SELECT TerritoryID, COUNT(CustomerID) AS CustomerCount
FROM Sales.Customer
GROUP BY TerritoryID
ORDER BY CustomerCount DESC;

--50.	Which territory is having more customers (hint: customer)
SELECT  TerritoryID, COUNT(CustomerID) AS CustomerCount
FROM Sales.Customer
GROUP BY TerritoryID
ORDER BY CustomerCount DESC



--51.	Which territory is having more stores (hint: customer)
 SELECT  TerritoryID, COUNT(StoreID) AS Store_Count
FROM Sales.Customer
GROUP BY TerritoryID
ORDER BY Store_Count DESC

--52.	 Is there any person having more than one credit card (hint: PersonCreditCard)
select CONCAT_WS(' ',p.FirstName,p.LastName)as PersonName,COUNT(pc.CreditCardID)as CreditCardCount
from Person.Person p
join sales.PersonCreditCard pc
on p.BusinessEntityID=pc.BusinessEntityID
group by p.FirstName,p.LastName
having count(pc.CreditCardID)>1

--53.	Find the product wise sale price (sales order details)
SELECT p.ProductID, p.Name AS ProductName, 
       SUM(sod.OrderQty * sod.UnitPrice) AS TotalSalesPrice
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalSalesPrice DESC

--54.	Find the total values for line total product having maximum order
 select * from Purchasing.PurchaseOrderDetail

 select Top 1 PurchaseOrderID,
 sum(LineTotal)as TotalLines,
 max(OrderQty)as Max_Order
 from Purchasing.PurchaseOrderDetail
 group by PurchaseOrderID
 having max(OrderQty)>1



 --55.Calculate the age of employees

 select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--56.Calculate the year of experience of the employee based on hire date
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.HireDate)Experience
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--57.	Find the age of employee at the time of joining
SELECT BusinessEntityID,BirthDate, HireDate, 
    DATEDIFF(YEAR, BirthDate, HireDate) AS AgeAtJoining
FROM HumanResources.Employee

--58.Find the average age of male and female

select Gender,Avg(datediff(YEAR,birthdate,GETDATE()))Avg_Age from HumanResources.Employee
group by Gender



--59.Which product is the oldest product as on the date (refer  the product sell start date)
select top 1 name,
 max(year(getdate())-year(SellStartDate))as productage
 from Production.Product
 group by Name






 --60.Display the product name, standard cost, and time duration for the same cost. (Product cost history)
  select * from Production.ProductCostHistory

  select p.Name,
         ph.StandardCost,
	     DATEDIFF(YEAR,ph.EndDate,ph.StartDate)Time_duration,
         avg(ph.Standardcost)over(partition by DATEDIFF(YEAR,ph.EndDate,ph.StartDate))Avg_StandardCost
  from Production.ProductCostHistory ph
  join Production.Product p
  on p.ProductID=ph.ProductID
  where ph.EndDate is not null and
  ph.StartDate is not null

  --61.	Find the purchase id where shipment is done 1 month later of order date  
  Select * from Purchasing.ShipMethod
  select * from Purchasing.PurchaseOrderHeader

 select PurchaseOrderID
        
 from Purchasing.PurchaseOrderHeader where datediff(MONTH,OrderDate,ShipDate)=1 

 --62Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

 select sum(TotalDue)Total
 from Purchasing.PurchaseOrderHeader where datediff(MONTH,OrderDate,ShipDate)=1 


 --63.Find the average difference in due date and ship date based on  online order flag
 SELECT OnlineOrderFlag, 
       AVG(DATEDIFF(DAY, ShipDate, DueDate)) AS Avg_Days_Difference
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag

--64.	Display business entity id, marital status, gender, vacationhr, average vacation based on marital status

select * from HumanResources.Employee
select * from HumanResources.Department
select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by maritalstatus)Vac_Mari_Status
from HumanResources.Employee

--65Display business entity id, marital status, gender, vacationhr, average vacation based on gender

select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by gender)Avg_Based_Gender
from HumanResources.Employee
 
 --66.Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level

 select  BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by Organizationlevel )Vac__Org_level
from HumanResources.Employee

--67Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept


SELECT  
    e.BusinessEntityID, 
    e.HireDate, 
    d.Name AS DepartmentName, 
    COUNT(e.BusinessEntityID) OVER (PARTITION BY d.Name) AS DepartmentEmployeeCount,
    COUNT(e.BusinessEntityID) OVER (PARTITION BY d.Name, ed.OrganizationLevel) AS OrgLevelEmployeeCount,
    COALESCE(ed.OrganizationLevel, 0) AS OrganizationLevel -- Handling NULL values
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory ed 
    ON e.BusinessEntityID = ed.BusinessEntityID
JOIN HumanResources.Department d 
    ON ed.DepartmentID = d.DepartmentID;


--68.Display department name, average sick leave and sick leave per department
select distinct
	   d.Name DepartmentName,
	   avg (SickLeaveHours) over(Partition by d.departmentID)Depart_Wise_Sickleave,
	   count(SickLeaveHours) over(Partition by d.departmentid)Org_lev_Sickleave
	   from HumanResources.Employee e join HumanResources.EmployeeDepartmentHistory eh
	   on e.BusinessEntityID=eh.BusinessEntityID
	   join HumanResources.Department d on 
	   d.DepartmentID=eh.DepartmentID


--69.Display the employee details first name, last name,  with total count 
--of various shift done by the person and shifts count per department

Select * from Person.Person
select * from HumanResources.Shift
select * from HumanResources.Employee
select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory

select p.FirstName,
       p.LastName,
	   Count(s.ShiftID)TotalShift,
	   count(*)over(partition by d.departmentid)Dept_Shift_count
from Person.Person p
join HumanResources.Employee e
on p.BusinessEntityID=e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory ed
on ed.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=ed.DepartmentID
join HumanResources.Shift s
on s.ShiftID=ed.ShiftID
group by e.BusinessEntityID,p.FirstName,p.LastName,d.DepartmentID,d.Name

--70.Display country region code, group average sales quota based on territory id
select * from Sales.SalesPerson
select * from Sales.SalesTerritory

select st.CountryRegionCode,
       st.[Group],
	   avg(sp.SalesQuota) as Avg_SalesQuota
from Sales.SalesTerritory st
join Sales.SalesPerson sp
on sp.TerritoryID=st.TerritoryID
where SalesQuota is not null
group by st.CountryRegionCode,st.[Group]
order by st.CountryRegionCode,Avg_SalesQuota Desc




--71.	Display special offer description, category and avg(discount pct) per the category


Select * from Sales.SpecialOfferProduct
Select * from Sales.SpecialOffer

select distinct description,
        Category,
		avg(DiscountPct)over(partition by  category)Avg_By_Dispt_Cat
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID

--72.	Display special offer description, category and avg(discount pct) per the month

SELECT distinct
    Description, 
    Category, 
    Month(StartDate) AS OfferMonth,
    AVG(DiscountPct) OVER (PARTITION BY Month(StartDate)) AS Avg_Discount_By_Year
FROM Sales.SpecialOffer so
JOIN Sales.SpecialOfferProduct sp 
    ON sp.SpecialOfferID = so.SpecialOfferID;

--73.	Display special offer description, category and avg(discount pct) per the year
SELECT distinct
    Description, 
    Category, 
    YEAR(StartDate) AS OfferYear,
	
    AVG(so.DiscountPct) OVER (PARTITION BY YEAR(so.StartDate),Year(so.Enddate)) AS Avg_Discount_By_Year
FROM Sales.SpecialOffer so
JOIN Sales.SpecialOfferProduct sp 
    ON sp.SpecialOfferID = so.SpecialOfferID;


--74.	Display special offer description, category and avg(discount pct) per the type
select distinct description,
        Category,
		avg(DiscountPct)over(partition by  type)Avg_By_Dispt_Type
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID



--75.	Using rank and dense rank find territory wise top sales person
 select * from Sales.SalesTerritory
 select * from HumanResources.Employee

SELECT 
    sp.BusinessEntityID,
    st.TerritoryID,
    st.Name AS TerritoryName,
    sp.SalesYTD,
    RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS Rank_YTD,
    DENSE_RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS Dense_Rank_YTD
FROM Sales.SalesPerson sp
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
WHERE sp.SalesYTD IS NOT NULL
ORDER BY st.TerritoryID, Rank_YTD;
