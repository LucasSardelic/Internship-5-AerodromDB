--Kreiranje tablica

CREATE TABLE Airports(
	AirportId SERIAL Primary Key,
	Name VARCHAR(30) NOT NULL,
	Latitude FLOAT,
	Longitude FLOAT
)
ALTER TABLE Airports
	ADD City VARCHAR(30)

CREATE TABLE Users(
	UserId SERIAL Primary Key,
	Name VARCHAR(30) NOT NULL,
	LoyaltyCard VARCHAR(1)
)

CREATE TABLE Planes(
	PlaneId SERIAL Primary Key,
	Company VARCHAR(30),
	Type VARCHAR(30),
	Activity VARCHAR(10),
	Capacity INT,
	DateOfCreation TIMESTAMP
)
ALTER TABLE Planes
	ALTER COLUMN Activity TYPE VARCHAR(20)

ALTER TABLE Planes
	ADD Name VARCHAR(30)

CREATE TABLE PlaneAirports(
	PlaneId INT REFERENCES Planes(PlaneId),
	AirportId INT REFERENCES Airports(AirportId),
	PRIMARY KEY(PlaneId, AirportId)
)

CREATE TABLE Flights(
	FlightId SERIAL Primary Key,
	Planes INT REFERENCES Planes(PlaneId),
	Departure INT REFERENCES Airports(AirportId),
	Arrival INT REFERENCES Airports(AirportId),
	DateOfDeaparture TIMESTAMP,
	Length INT
)

CREATE TABLE Cards(
	CardId SERIAL Primary Key,
	Seat VARCHAR(2),
	Custommer INT REFERENCES Users(UserId),
	FlightCard INT REFERENCES Flights(FlightId),
	PlaneCard INT REFERENCES Planes(PlaneId),
	Grade INT,
	Review VARCHAR(50)
)

ALTER TABLE Cards
	ADD Price FLOAT

CREATE TABLE Staff(
	StaffId SERIAL Primary Key,
	Name VARCHAR(30) NOT NULL,
	Flight INT REFERENCES Flights(FlightId),
	Birth TIMESTAMP,
	Gender VARCHAR(1),
	IsPilot BOOL
)
Alter TABLE Staff
	ADD Pay FLOAT

CREATE TABLE FlightStaff(
	FlightId INT REFERENCES Flights(FlightId),
	StaffId INT REFERENCES Staff(StaffId),
	PRIMARY KEY(FlightId, StaffId)
)

--Upiti

SELECT Name, Type FROM Planes
	WHERE Capacity > 100

SELECT * FROM Cards
	WHERE Price BETWEEN 100 AND 200

SELECT * FROM Staff
	WHERE (Staff.Gender = 'F') 
	AND (Staff.IsPilot = true) 
	AND (select count(*) FROM Flights where Flights.DateOfDeaparture<CURRENT_TIMESTAMP AND
		(select count(*) FROM FlightStaff sf where Flights.FlightId = sf.FlightId 
		 AND sf.StaffId = Staff.StaffId)>0) >20

SELECT count(*) FROM Flights fl
	WHERE (SELECT name FROM Airports ap where ap.AirportId = fl.Departure)='Split'
	OR (SELECT name FROM Airports ap where ap.AirportId = fl.Arrival)='Split'
	AND EXTRACT('Year' from fl.DateOfDeaparture) = 2023

select * from Flights fl
	where (SELECT name FROM Airports ap where ap.AirportId = fl.Arrival)='Vienna'
	AND EXTRACT('Year' from fl.DateOfDeaparture) = 2023
	AND EXTRACT('Year' from fl.DateOfDeaparture) = 12

select count(*) from Flights fl
	where (select Seat from Cards where fl.FlightId = Cards.FlightCard) ='B%'
	AND EXTRACT('Year' from fl.DateOfDeaparture) = 2021
	AND (select Company from Planes where fl.Planes = Planes.PlaneId) = 'AirDump'

select Grade from Cards
	where(select Company from Planes where Planes.PlaneId = Cards.PlaneCard)='AirDump'

select * from Airports
where Airports.City = 'London'
ORDER BY (select count(*) from Flights where
		 EXTRACT (EPOCH FROM (CURRENT_TIMESTAMP - DateOfDeaparture)) < 1800 
		 AND EXTRACT (EPOCH FROM (CURRENT_TIMESTAMP - DateOfDeaparture)) >0
		 AND (select Type from Planes where Flights.Planes = Planes.PlaneId)='Airbus')

--Nism pronasao kako u sql kalkulirati latitudu i longitudu u distancu, tako da sam taj zadatak preskocio

UPDATE Cards
Set Price = Price*0.8
where (select count(*) from Cards 
	   where (select FlightId from Flights where Cards.FlightCard = Flights.FlightId)= Cards.FlightCard)<20

UPDATE Staff
Set Pay = 100 + Pay
where(select count(*) from Flights
	 where Flights.Length>10)>10

UPDATE Planes
	Set Activity = 'Deconstructed'
	where(EXTRACT('Year' from (DateOfCreation - CURRENT_TIMESTAMP)) >20)
	AND(select count(*) FROM Flights where Flights.DateOfDeaparture>CURRENT_TIMESTAMP)=0

DELETE FROM Flights
	where(select count(*) from Cards where Cards.FlightCard = Flights.FlightId)=0

UPDATE Users
	Set LoyaltyCard = 'N'
	where name = '%ov' 
	OR name = '%ova' 
	OR name='%in' 
	OR name='%ina'