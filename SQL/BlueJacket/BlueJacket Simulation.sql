USE BlueJacket

-- Sales Transaction

-- 1.Display jacket
Select 
	JacketID,
	BrandName,
	TypeName,
	SalesPrice AS [Price]
From MsJacket mj
Join MsBrand mb ON mb.BrandID = mj.BrandID
Join MsType mt ON mt.TypeID = mb.TypeID

-- 2. Insert customer data
Insert Into MsCustomer Values
('MC011', 'Dylan' , 'Male' , 'Bandung Street', '081212340011')

-- 3. Insert into sales 
Insert Into SalesHeader Values
('SH034', '2022-06-16', 'MC011', 'MS009')

Insert Into SalesDetail Values
(2, 'MJ001', 'SH034'),
(1, 'MJ002', 'SH034')

-- 4. Give bills
Select
	sh.SalesID,
	StaffID,
	[Staff Name] = ASMsStaff.StaffName,
	[Staff Phone] = ASMsStaff.StaffPhone,
	[Customer Name] = ASMsCustomer.CustomerName,
	[Customer Phone] = ASMsCustomer.CustomerPhone,
	[Jacket ID] = JacketID,
	[Jacket Brand] = ASMsJacket.BrandName,
	[Jacket Type] = ASMsJacket.TypeName,
	[Jacket Price] = ASMsJacket.JacketPrice,
	[Quantity] = ASMsSales.Quantity,
	[Total] = ASMsSales.Total,
	[Transaction Date] = ASMsSales.TransactionDate
From SalesHeader sh
Join SalesDetail sd ON sd.SalesID = sh.SalesID,
(
	Select 
		StaffName AS [StaffName],
		StaffPhone AS [StaffPhone]
	From MsStaff
	Where StaffID LIKE 'MS009'

) ASMsStaff,
(
	Select 
		CustomerName AS [CustomerName],
		CustomerPhone AS [CustomerPhone]
	From MsCustomer
	Where CustomerID LIKE 'MC011'
	
) ASMsCustomer,
(
	Select 
		BrandName,
		TypeName,
		SalesPrice AS [JacketPrice]
	From MsJacket mj
	Join MsBrand mb ON mb.BrandID = mj.BrandID
	Join MsType mt ON mt.TypeID = mb.TypeID
	Where JacketID IN ( 'MJ001', 'MJ002' )	
) ASMsJacket,
(
	Select 
		SalesQuantity AS [Quantity],
		SalesDate AS [TransactionDate],
		SUM(SalesQuantity * SalesPrice) AS [Total]
	From SalesHeader sh
	Join SalesDetail sd ON sd.SalesID = sh.SalesID
	Join MsJacket mj ON mj.JacketID = sd.JacketID
	Join MsBrand mb ON mb.BrandID = mj.BrandID
	Join MsType mt ON mt.TypeID = mb.TypeID
	Where sh.SalesID LIKE 'SH034'
	Group By SalesQuantity, SalesDate
) ASMsSales
Where sh.SalesID LIKE 'SH034'

-- 5. Update stock 

-- If stock > 0

Update MsJacket
Set Stock = Stock - Sales.Quantity
From MsJacket,
(
	Select [Quantity] = sd.SalesQuantity
	From SalesDetail sd
	Join SalesHeader sh ON sd.SalesID = sh.SalesID
	Where sh.SalesID LIKE 'SH034'
) Sales
Where JacketID IN ( 'MJ001', 'MJ002' )

-- If stock = 0
Delete From MsJacket
Where Stock = 0

-- Purchase Transaction

-- 1. Check stock

SELECT * FROM MsJacket
ORDER BY Stock ASC

-- 2. Input Data From Vendor If Vendor Is New

INSERT INTO MsVendor VALUES
('MV011', 'NikitaFashion', 'nikitafashion@gmail.com', '83251834591', 'Jl.Bakso')

-- 3. Insert Purchase Data

-- If new vendor and new jacket
INSERT INTO PurchaseHeader VALUES
('MC021', '2022-06-16', 'MV011', 'MS004' )

INSERT INTO PurchaseDetail VALUES
( 15, 'MJ011', 'MC021' )

INSERT INTO MsType VALUES
('JT011', 'Sweater')

INSERT INTO MsBrand VALUES
('JB011', 'JT011', 'Royco')

INSERT INTO MsJacket VALUES
('MJ011', 'JB011', 25000, 75000, 10)

-- If vendor is exists and update stock
INSERT INTO PurchaseHeader VALUES
('MC022', '2022-06-16', 'MV001', 'MS007' )

INSERT INTO PurchaseDetail VALUES
( 2, 'MJ001', 'MC022' )

Update MsJacket
Set Stock = Stock + Purchase.Quantity
From MsJacket,
(
	Select [Quantity] = pd.PurchaseQuantity
	From PurchaseDetail pd
	Join PurchaseHeader ph ON pd.PurchaseID = ph.PurchaseID
	Where ph.PurchaseID LIKE 'MC022'
) Purchase
Where JacketID IN ( 'MJ001')