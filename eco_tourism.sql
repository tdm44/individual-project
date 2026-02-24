DROP DATABASE IF EXISTS eco_tourism;
CREATE DATABASE eco_tourism;
USE eco_tourism;

-- CUSTOMER
CREATE TABLE Customer (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  FullName VARCHAR(150) NOT NULL,
  Email VARCHAR(150) NOT NULL UNIQUE,
  Phone VARCHAR(40),
  Nationality VARCHAR(80),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- AGENT
CREATE TABLE Agent (
  AgentID INT AUTO_INCREMENT PRIMARY KEY,
  FullName VARCHAR(150) NOT NULL,
  Email VARCHAR(150) UNIQUE,
  Phone VARCHAR(40),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- SUPPLIER
CREATE TABLE Supplier (
  SupplierID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(200) NOT NULL,
  SupplierType VARCHAR(50), -- e.g., 'hotel','guide','transport'
  ContactInfo VARCHAR(300),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ATTRACTION
CREATE TABLE Attraction (
  AttractionID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(250) NOT NULL,
  City VARCHAR(100),
  Country VARCHAR(100),
  AttractionType VARCHAR(80),
  Capacity INT DEFAULT NULL,
  SupplierID INT DEFAULT NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- TOUR_PACKAGE
CREATE TABLE TourPackage (
  PackageID INT AUTO_INCREMENT PRIMARY KEY,
  Title VARCHAR(250) NOT NULL,
  Description TEXT,
  DurationDays INT,
  BasePrice DECIMAL(10,2),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- PACKAGE_ATTRACTION (associative)
CREATE TABLE PackageAttraction (
  PackageID INT NOT NULL,
  AttractionID INT NOT NULL,
  SequenceOrder INT DEFAULT 1,
  
  PRIMARY KEY (PackageID, AttractionID),
  FOREIGN KEY (PackageID) REFERENCES TourPackage(PackageID) ON DELETE CASCADE,
  FOREIGN KEY (AttractionID) REFERENCES Attraction(AttractionID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ROOM
CREATE TABLE Room (
  RoomID INT AUTO_INCREMENT PRIMARY KEY,
  SupplierID INT NOT NULL,
  RoomType VARCHAR(80),
  Price DECIMAL(10,2),
  Capacity INT DEFAULT 2,
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- BOOKING
CREATE TABLE Booking (
  BookingID INT AUTO_INCREMENT PRIMARY KEY,
  BookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  StartDate DATE,
  EndDate DATE,
  Status ENUM('BOOKED','CONFIRMED','CANCELLED','COMPLETED') DEFAULT 'BOOKED',
  TotalAmount DECIMAL(12,2) DEFAULT 0,
  CustomerID INT NOT NULL,
  AgentID INT DEFAULT NULL,
  PackageID INT NOT NULL,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE RESTRICT,
  FOREIGN KEY (PackageID) REFERENCES PackageAttraction(PackageID) ON DELETE RESTRICT,
  FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- BOOKING_ITEM (polymorphic item reference)
CREATE TABLE BookingItem (
  BookingItemID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  ItemType ENUM('PACKAGE','ATTRACTION','ROOM') NOT NULL,
  ItemRefID INT NOT NULL,
  Quantity INT DEFAULT 1,
  Price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- PAYMENT
CREATE TABLE Payment (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  Amount DECIMAL(12,2) NOT NULL,
  Method ENUM('CARD','CASH','ONLINE') DEFAULT 'ONLINE',
  Status ENUM('PENDING','COMPLETED','FAILED') DEFAULT 'COMPLETED',
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Indexes for performance
CREATE INDEX idx_booking_customer ON Booking(CustomerID);
CREATE INDEX idx_attraction_city ON Attraction(City);
CREATE INDEX idx_package_price ON TourPackage(BasePrice);

-- CUSTOMER
INSERT INTO Customer (FullName, Email, Phone, Nationality) VALUES
('Alice Patel','alice@example.com','+91-9876543210','India'),
('John Smith','john@example.com','+44-7700-900000','UK'),
('Maria Lopez','maria@example.com','+34-600123456','Spain'),
('David Chen','davidc@example.com','+86-13500001111','China'),
('Fatima Khan','fatima@example.com','+971-500000123','UAE');

-- AGENT
INSERT INTO Agent (FullName, Email, Phone) VALUES
('Meera Rao','meera.agent@example.com','+91-9000000001'),
('Ravi Kumar','ravi.agent@example.com','+91-9888888888'),
('Sophia Brown','sophia.agent@example.com','+44-7711111111'),
('Carlos Fernandez','carlos.agent@example.com','+34-611111111'),
('Li Wei','liwei.agent@example.com','+86-13999999999');

-- SUPPLIER
INSERT INTO Supplier (Name, SupplierType, ContactInfo) VALUES
('GreenTrail Lodges','hotel','info@greentrail.example'),
('WildWalk Guides','guide','contact@wildwalk.example'),
('EcoStay Resorts','hotel','contact@ecostay.example'),
('NatureWay Transport','transport','support@natureway.example'),
('BlueBay Guides','guide','help@bluebayguides.example');

-- ATTRACTION
INSERT INTO Attraction (Name, City, Country, AttractionType, Capacity, SupplierID) VALUES
('Riverbank Nature Reserve','Coorg','India','Forest',50,2),
('Blue Lagoon Marine Sanctuary','Andaman','India','Marine',30,NULL),
('Desert Oasis Camp','Dubai','UAE','Desert',100,3),
('Rainforest Expedition','Goa','India','Jungle',40,2),
('Sierra Mountain Trek','Granada','Spain','Mountain',25,5);

-- TOUR_PACKAGE
INSERT INTO TourPackage (Title, Description, DurationDays, BasePrice) VALUES
('Coorg Wildlife Weekend','Weekend trip to Coorg reserve',3,350.00),
('Andaman Marine Eco Tour','3-day marine conservation focused tour',4,650.00),
('Dubai Desert Safari','Eco-friendly desert camping and stargazing',2,500.00),
('Goa Rainforest Adventure','Exploring tropical rainforest ecosystems',5,700.00),
('Spain Sierra Trek','Mountain trekking with local guides',6,1200.00);

-- PACKAGE_ATTRACTION
INSERT INTO PackageAttraction (PackageID, AttractionID, SequenceOrder) VALUES
(1,1,1),
(2,2,1),
(3,3,1),
(4,4,1),
(5,5,1);

-- ROOM
INSERT INTO Room (SupplierID, RoomType, Price, Capacity) VALUES
(1,'Deluxe Cottage',120.00,2),
(1,'Family Suite',200.00,4),
(3,'Eco Villa',180.00,3),
(3,'Standard Room',90.00,2),
(1,'Tent Stay',50.00,2);

-- BOOKING
INSERT INTO Booking (StartDate, EndDate, Status, TotalAmount, CustomerID, AgentID,PackageID) VALUES
('2025-10-10','2025-10-12','BOOKED',350.00,1,1,1),
('2025-11-05','2025-11-09','CONFIRMED',650.00,2,2,2),
('2025-12-01','2025-12-03','BOOKED',500.00,3,3,3),
('2026-01-15','2026-01-20','CANCELLED',700.00,4,4,4),
('2026-02-10','2026-02-16','BOOKED',1200.00,5,5,5);

-- BOOKING_ITEM
INSERT INTO BookingItem (BookingID, ItemType, ItemRefID, Quantity, Price) VALUES
(1,'PACKAGE',1,1,350.00),
(2,'PACKAGE',2,1,650.00),
(3,'PACKAGE',3,1,500.00),
(4,'PACKAGE',4,1,700.00),
(5,'PACKAGE',5,1,1200.00);

-- PAYMENT
INSERT INTO Payment (BookingID, Amount, Method, Status) VALUES
(1,350.00,'CARD','COMPLETED'),
(2,650.00,'ONLINE','COMPLETED'),
(3,500.00,'CASH','PENDING'),
(4,700.00,'CARD','FAILED'),
(5,1200.00,'ONLINE','COMPLETED');


-- CUSTOMER
SELECT * FROM Customer;

-- AGENT
SELECT * FROM Agent;

-- SUPPLIER
SELECT * FROM Supplier;

-- ATTRACTION
SELECT * FROM Attraction;

-- TOUR_PACKAGE
SELECT * FROM TourPackage;

-- PACKAGE_ATTRACTION
SELECT * FROM PackageAttraction;

-- ROOM
SELECT * FROM Room;

-- BOOKING
SELECT * FROM Booking;

-- BOOKING_ITEM
SELECT * FROM BookingItem;

-- PAYMENT
SELECT * FROM Payment;

