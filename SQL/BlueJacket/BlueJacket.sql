CREATE DATABASE BlueJacket

USE BlueJacket

SELECT * FROM MsStaff
SELECT * FROM MsCustomer
SELECT * FROM MsVendor
SELECT * FROM MsType
SELECT * FROM MsBrand
SELECT * FROM MsJacket
SELECT * FROM PurchaseHeader
SELECT * FROM PurchaseDetail
SELECT * FROM SalesHeader
SELECT * FROM SalesDetail

DROP TABLE MsStaff
DROP TABLE MsCustomer
DROP TABLE MsVendor
DROP TABLE MsType
DROP TABLE MsBrand
DROP TABLE MsJacket
DROP TABLE PurchaseHeader
DROP TABLE PurchaseDetail
DROP TABLE SalesHeader
DROP TABLE SalesDetail

CREATE TABLE MsStaff (
	StaffID char(5) PRIMARY KEY CHECK (StaffID LIKE 'MS[0-9][0-9][0-9]') NOT NULL,
	StaffName varchar(50),
	StaffGender varchar(50),
	CONSTRAINT StaffGender check (StaffGender like 'Male' or StaffGender like 'Female'),
	StaffEmail varchar(50),
	StaffPhone numeric(19,0),
	StaffSalary int,
	CONSTRAINT StaffSalary check (StaffSalary between 4000000 and 100000000)
)

Create table MsCustomer (
	CustomerID char(5) PRIMARY KEY CHECK (CustomerID LIKE 'MC[0-9][0-9][0-9]'),
	CustomerName varchar(50),
	CustomerGender varchar(50),
	CONSTRAINT CustomerGender check (CustomerGender like 'Male' or CustomerGender like 'Female'),
	CustomerAddress varchar(50) check (CustomerAddress like '%Street%'),
	CustomerPhone numeric(19,0)
)

CREATE TABLE MsVendor(
	VendorID CHAR(5) PRIMARY KEY CHECK (VendorID LIKE 'MV[0-9][0-9][0-9]'),
	VendorName Varchar(50),
	VendorEmail Varchar(50),
	VendorPhone numeric(19,0),
	VendorAddress Varchar(50)

)

CREATE TABLE MsType (

	TypeID char(5) PRIMARY KEY CHECK ( TypeID like 'JT[0-9][0-9][0-9]'),
	TypeName varchar(50)

)

CREATE TABLE MsBrand (

	BrandID char(5) PRIMARY KEY CHECK ( BrandID like 'JB[0-9][0-9][0-9]' ),
	TypeID char(5) FOREIGN KEY REFERENCES MsType(TypeID) ON UPDATE CASCADE ON DELETE CASCADE,
	BrandName varchar(50)
)

CREATE TABLE MsJacket (

	JacketID char(5) PRIMARY KEY CHECK ( JacketID like 'MJ[0-9][0-9][0-9]' ),
	BrandID char(5) FOREIGN KEY REFERENCES MsBrand(BrandID) ON UPDATE CASCADE ON DELETE CASCADE,
	PurchasePrice int check (PurchasePrice between 0 and 500000000),
	SalesPrice int check (SalesPrice between 0 and 500000000),
	Stock int check (Stock between 0 and 1000)

)


CREATE TABLE PurchaseHeader(

	PurchaseID Char(5) PRIMARY KEY CHECK (PurchaseID LIKE 'MC[0-9][0-9][0-9]'),
	PurchaseDate Date CHECK(DATENAME(WEEKDAY, PurchaseDate) NOT LIKE 'Sunday'),
	VendorID Char(5) FOREIGN KEY REFERENCES MsVendor(VendorID) ON UPDATE CASCADE ON DELETE CASCADE,
	StaffID Char (5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE

)


CREATE TABLE PurchaseDetail (

	PurchaseQuantity int check (PurchaseQuantity between 0 and 100),
	JacketID char(5) FOREIGN KEY REFERENCES MsJacket(JacketID) ON UPDATE CASCADE ON DELETE CASCADE,
	PurchaseID char(5) FOREIGN KEY REFERENCES PurchaseHeader(PurchaseID) ON UPDATE CASCADE ON DELETE CASCADE

)

Create TABLE SalesHeader (

	SalesID char(5) PRIMARY KEY CHECK (SalesID LIKE 'SH[0-9][0-9][0-9]'),
	SalesDate Date CHECK(DATENAME(WEEKDAY, SalesDate) NOT LIKE 'Sunday'),
	CustomerID char(5) FOREIGN KEY REFERENCES MsCustomer(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE,
	StaffID char(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE

)


Create TABLE SalesDetail (

 SalesQuantity int check (SalesQuantity between 0 and 100),
 JacketID char(5) FOREIGN KEY REFERENCES MsJacket(JacketID) ON UPDATE CASCADE ON DELETE CASCADE,
 SalesID char(5) FOREIGN KEY REFERENCES SalesHeader(SalesID) ON UPDATE CASCADE ON DELETE CASCADE

)
