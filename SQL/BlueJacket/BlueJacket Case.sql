USE BlueJacket

-- 1
Select 
	mv.VendorID,
	mv.VendorName,
	mv.VendorEmail,
	Sum(pd.PurchaseQuantity) AS [TotalJacketPurchased],
	Count(ph.PurchaseID)  AS [TotalTransaction]
From MsVendor mv
Join PurchaseHeader ph ON ph.VendorID = mv.VendorID
Join PurchaseDetail pd ON pd.PurchaseID = ph.PurchaseID
Where DATENAME(Weekday, PurchaseDate) LIKE 'Tuesday'
AND DATEDIFF(Month, PurchaseDate, '2022-06-15') > 3
Group By mv.VendorID,mv.VendorName,	mv.VendorEmail

-- 2
 SELECT 
 ph.StaffID,
 StaffName,
 VendorName,
 COUNT(*) as [Total Transaction]
FROM MsStaff mf
 JOIN PurchaseHeader ph on mf.StaffID = ph.StaffID
 JOIN MsVendor mv on ph.VendorID = mv.VendorID
Where StaffGender like 'female'
 AND DATENAME(WEEKDAY, PurchaseDate) = 'Monday'
Group BY ph.StaffID, StaffName, VendorName, PurchaseDate

-- 3

Select 
	mv.VendorID,
	mv.VendorName,
	mv.VendorEmail,
	Sum(pd.PurchaseQuantity) AS [TotalJacketPurchased],
	Count(ph.PurchaseID)  AS [TotalTransaction]
From MsVendor mv
Join PurchaseHeader ph ON ph.VendorID = mv.VendorID
Join PurchaseDetail pd ON pd.PurchaseID = ph.PurchaseID
Where DATENAME(Weekday, PurchaseDate) LIKE 'Tuesday'
AND DATEDIFF(Month, PurchaseDate, '2022-06-15') > 3
Group By mv.VendorID,mv.VendorName,	mv.VendorEmail

-- 4

Select
	ms.StaffID,
	ms.StaffName,
	Sum(sd.SalesQuantity) AS [TotalJacketSold]
From MsStaff ms
Join SalesHeader sh ON sh.StaffID = ms.StaffID
Join SalesDetail sd ON sd.SalesID = sh.SalesID,
(
	Select 
		ms2.StaffID,
		Count(sh2.SalesID) AS [TransactionCount]
	From MsStaff ms2
	Join SalesHeader sh2 ON sh2.StaffID = ms2.StaffID
	Where DATEDIFF(Month, SalesDate, '2022-06-15') >= 6
	Group By ms2.StaffID
	HAVING Count(sh2.SalesID) >= 3
) x
Where ms.StaffID IN (x.StaffID)
Group By ms.StaffID, ms.StaffName

-- 5
SELECT LEFT(StaffName, CHARINDEX(' ', StaffName) - 1) AS StaffName, StaffSalary, VendorName,
YEAR(PurchaseDate) AS [Year]
FROM MsStaff ms
JOIN PurchaseHeader ph ON ms.StaffID = ph.StaffID
JOIN MsVendor mv ON ph.VendorID = mv.VendorID,(
 SELECT AVG(StaffSalary) AS average
 FROM MsStaff) AS sq1
WHERE YEAR(PurchaseDate) = 2021
AND StaffSalary > sq1.average

-- 6
SELECT StaffName, STUFF(StaffPhone, 1, 1, '+62') AS StaffPhone, CustomerName,
CONVERT(VARCHAR(255), SalesDate, 107) AS SalesDate
FROM MsStaff ms
JOIN SalesHeader sh ON ms.StaffID = sh.StaffID
JOIN MsCustomer mc ON sh.CustomerID = mc.CustomerID,(
 SELECT MIN(StaffSalary) AS [min]
 FROM MsStaff) AS sq1
WHERE MONTH(SalesDate) = 5
AND StaffSalary = sq1.[min]

-- 7
Select CustomerName, LEFT(CustomerGender, 1) AS CustomerGender, CustomerAddress,
CONCAT('Rp. ', SUM(SalesPrice * SalesQuantity)) AS JacketSalesPrice
From MsCustomer mc
 JOIN SalesHeader sh on mc.CustomerID = sh.CustomerID
 JOIN SalesDetail sd on sh.SalesID = sd.SalesID
 JOIN MsJacket mj on sd.JacketID = mj.JacketID, (
  Select mc.CustomerID,
   SUM(sd.SalesQuantity) as [TotalSales]
  From MsCustomer mc
   JOIN SalesHeader sh on mc.CustomerID = sh.CustomerID
   JOIN SalesDetail sd on sh.SalesID = sd.SalesID
  Group by mc.CustomerID
) x, (
  Select Max([TotalSales]) as [MinumumSales]
  From (
  Select mc.CustomerID,
   SUM(sd.SalesQuantity) as [TotalSales]
  From MsCustomer mc
   JOIN SalesHeader sh on mc.CustomerID = sh.CustomerID
   JOIN SalesDetail sd on sh.SalesID = sd.SalesID
  Group by mc.CustomerID
 ) x
) y
WHERE DATENAME(MONTH, SalesDate) NOT IN ('March')
and x.CustomerID = mc.CustomerID
and x.TotalSales = y.MinumumSales
Group by CustomerName, CustomerGender, CustomerAddress

-- 8
SELECT ph.PurchaseID, PurchaseDate, ms.StaffID, left(StaffName, CHARINDEX(' ', StaffName) -1)
AS [StaffName], StaffEmail
FROM PurchaseHeader ph
JOIN MsStaff ms ON ph.StaffID = ms.StaffID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID,(
 Select mf.StaffID,
  SUM(pd.PurchaseQuantity) as [TotalTransaction]
 From MsStaff mf
  JOIN PurchaseHeader ph on mf.StaffID = ph.StaffID
  JOIN PurchaseDetail pd on ph.PurchaseID = pd.PurchaseID
 Group BY mf.StaffID
) x, (
 Select MIN([TotalTransaction]) AS [MinumumTransaction]
 From (
 Select mf.StaffID,
  SUM(pd.PurchaseQuantity) as [TotalTransaction]
 From MsStaff mf
  JOIN PurchaseHeader ph on mf.StaffID = ph.StaffID
  JOIN PurchaseDetail pd on ph.PurchaseID = pd.PurchaseID
 Group BY mf.StaffID
 ) x

) y
WHERE DATENAME(WEEKDAY, PurchaseDate) = 'Monday'
and x.StaffID = ph.StaffID
and x.TotalTransaction = y.MinumumTransaction
GROUP BY ph.PurchaseID, PurchaseDate, StaffName
, StaffEmail, ms.StaffID

-- 9
CREATE VIEW JacketPurchase AS
 SELECT 
 ph.PurchaseID, 
 MONTH(PurchaseDate) AS [PurchaseMonth],
 COUNT(mj.JacketID) AS [TotalJacketBrand],
 SUM(PurchasePrice * PurchaseQuantity) AS [TotalPurchasePrice]
 FROM PurchaseHeader ph
 JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
 JOIN MsJacket mj ON pd.JacketID = mj.JacketID
 JOIN MsBrand mb ON mj.BrandID = mj.BrandID
 WHERE MONTH(PurchaseDate) = 6
 GROUP BY ph.PurchaseID, PurchaseDate
 HAVING SUM(PurchasePrice * PurchaseQuantity) > 5000000

 -- 10
 CREATE VIEW JacketSales AS
 SELECT 
 sh.SalesID,
 CONVERT(VARCHAR(255), SalesDate, 107) AS SalesDate,
 COUNT(TypeName) AS TotalJacketType,
 CONCAT('Rp. ', SUM(SalesPrice * SalesQuantity)) AS TotalSalesType
 FROM SalesHeader sh
 JOIN SalesDetail sd ON sh.SalesID = sd.SalesID
 JOIN MsJacket mj ON sd.JacketID = mj.JacketID
 JOIN MsBrand mb ON mj.BrandID = mb.BrandID
 JOIN MsType mt ON mb.TypeID = mt.TypeID
 WHERE MONTH(SalesDate) = 7 
 AND DATENAME(WEEKDAY, SalesDate) NOT LIKE ('Friday')
 GROUP BY sh.SalesID, SalesDate




