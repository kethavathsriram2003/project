CREATE DATABASE airline_reservation;
USE airline_reservation;


-- Flights Table
CREATE TABLE Flights (
flight_id INT AUTO_INCREMENT PRIMARY KEY,
flight_number VARCHAR(10) UNIQUE NOT NULL,
source VARCHAR(50) NOT NULL,
destination VARCHAR(50) NOT NULL,
departure_time DATETIME NOT NULL,
arrival_time DATETIME NOT NULL,
price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);
CREATE TABLE Customer (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
phone VARCHAR(15) UNIQUE
);
CREATE TABLE Seats (
seat_id INT AUTO_INCREMENT PRIMARY KEY,
flight_id INT NOT NULL,
seat_number VARCHAR(5) NOT NULL,
is_booked BOOLEAN DEFAULT 0,
UNIQUE(flight_id, seat_number),
FOREIGN KEY (flight_id) REFERENCES Flights(flight_id) ON DELETE CASCADE
);
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    customer_id INT NOT NULL,
    seat_id INT NOT NULL,
    booking_date DATE ,
    status ENUM('Confirmed','Cancelled') DEFAULT 'Confirmed',
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id)
);


INSERT INTO Flights VALUES
(NULL,'AI101','Delhi','Mumbai','2025-10-18 09:00:00','2025-10-18 11:15:00',4500),
(NULL,'AI102','Mumbai','Chennai','2025-10-18 13:00:00','2025-10-18 15:30:00',4800);


-- Customers
INSERT INTO Customer (name,email,phone) VALUES
('Ravi Kumar','ravi@example.com','9876543210'),
('Neha Sharma','neha@example.com','9998887776');


-- Seats
INSERT INTO Seats (flight_id, seat_number) VALUES
(1,'A1'),(1,'A2'),(2,'B1'),(2,'B2');


-- Bookings
INSERT INTO Bookings (flight_id, customer_id, seat_id,status) VALUES
(1,1,1,'Confirmed'),(2,2,4,'Confirmed');


-- Update seat status
UPDATE Seats SET is_booked=1 WHERE seat_id IN (1,4);


-- Check Available Flights
SELECT flight_id, flight_number, source, destination, departure_time, price
FROM Flights
WHERE source='Delhi' AND destination='Mumbai';


-- Check Available Seats
SELECT seat_id, seat_number FROM Seats
WHERE flight_id=1 AND is_booked=0;


-- Daily Booking Summary
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id=b.flight_id
GROUP BY f.flight_number;



-- After Booking Insert
DELIMITER $$

CREATE TRIGGER after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats
    SET is_booked = 1
    WHERE seat_id = NEW.seat_id;
END$$
-- After Booking Cancel
CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
IF NEW.status='Cancelled' THEN
UPDATE Seats SET is_booked=0 WHERE seat_id=NEW.seat_id;
END IF;
END$$
DELIMITER ;


CREATE VIEW flight_summary AS
SELECT f.flight_number,f.source,f.destination,
COUNT(b.booking_id) AS total_bookings,
SUM(f.price) AS estimated_revenue
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id=b.flight_id
GROUP BY f.flight_number,f.source,f.destination;


-- View Flight Summary
SELECT * FROM flight_summary;





