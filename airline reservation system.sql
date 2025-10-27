-- Create the database
CREATE DATABASE airline_reservation;
USE airline_reservation;

-- ===============================
-- 1. Create Tables
-- ===============================

-- Flights table
CREATE TABLE Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL UNIQUE,
    source VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Customers table

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

-- Seats table
CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    seat_number VARCHAR(5),
    is_booked BOOLEAN DEFAULT 0,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
    ON DELETE CASCADE
);

-- Bookings table
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    customer_id INT,
    seat_id INT,
    booking_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Confirmed', 'Cancelled') DEFAULT 'Confirmed',
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id)
);

-- ===============================
-- 2. Insert Sample Data
-- ===============================

-- Flights
INSERT INTO Flights (flight_number, source, destination, departure_time, arrival_time, price)
VALUES
('AI101', 'Delhi', 'Mumbai', '2025-10-18 09:00:00', '2025-10-18 11:15:00', 4500.00),
('AI102', 'Mumbai', 'Chennai', '2025-10-18 13:00:00', '2025-10-18 15:30:00', 4800.00),
('AI103', 'Bangalore', 'Kolkata', '2025-10-19 10:00:00', '2025-10-19 13:00:00', 5200.00);

-- Customers
INSERT INTO Customers (name, email, phone)
VALUES
('Ravi Kumar', 'ravi@example.com', '9876543210'),
('Neha Sharma', 'neha@example.com', '9998887776'),
('Amit Singh', 'amit@example.com', '9898989898');

-- Seats (for each flight, few sample seats)
INSERT INTO Seats (flight_id, seat_number) VALUES
(1, 'A1'), (1, 'A2'), (1, 'A3'), (1, 'A4'),
(2, 'B1'), (2, 'B2'), (2, 'B3'),
(3, 'C1'), (3, 'C2'), (3, 'C3');

-- Bookings (some sample confirmed bookings)
INSERT INTO Bookings (flight_id, customer_id, seat_id, status)
VALUES
(1, 1, 1, 'Confirmed'),
(2, 2, 5, 'Confirmed');

-- Update the booked seats
UPDATE Seats SET is_booked = 1 WHERE seat_id IN (1, 5);

-- ===============================
-- 3. Queries
-- ===============================

-- Find available seats for a specific flight
SELECT seat_number
FROM Seats
WHERE flight_id = 1 AND is_booked = 0;

-- Search for flights between two cities
SELECT flight_number, source, destination, departure_time, price
FROM Flights
WHERE source = 'Delhi' AND destination = 'Mumbai';

-- Daily booking summary
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_number;

-- ===============================
-- 4. Triggers
-- ===============================

-- Trigger to mark seat as booked after a booking
DELIMITER $$
CREATE TRIGGER after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats SET is_booked = 1 WHERE seat_id = NEW.seat_id;
END$$
DELIMITER ;

-- Trigger to mark seat as available when booking is cancelled
DELIMITER $$
CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'Cancelled' THEN
        UPDATE Seats SET is_booked = 0 WHERE seat_id = NEW.seat_id;
    END IF;
END$$
DELIMITER ;

-- ===============================
-- 5. Views
-- ===============================

-- View to summarize flights and bookings
CREATE VIEW flight_summary AS
SELECT 
    f.flight_number,
    f.source,
    f.destination,
    COUNT(b.booking_id) AS total_bookings,
    SUM(f.price) AS estimated_revenue
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_number, f.source, f.destination;

-- View the summary
SELECT * FROM flight_summary;

-- ===============================
-- ✅ End of Script
-- ===============================Check Available Flights
SELECT flight_id, flight_number, source, destination, departure_time, price
FROM Flights
WHERE source = 'Delhi' AND destination = 'Mumbai';

-- =====================================================
-- Check Available Seats for a Specific Flight
-- =====================================================

SELECT seat_id, seat_number
FROM Seats
WHERE flight_id = 1 AND is_booked = 0;

-- Check Booking Summary
SELECT b.booking_id, c.name, f.flight_number, s.seat_number, b.status
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Flights f ON b.flight_id = f.flight_id
JOIN Seats s ON b.seat_id = s.seat_id
WHERE b.customer_id = 2;

-- Insert Booking
INSERT INTO Bookings (flight_id, customer_id, seat_id, status)
VALUES (1, 2, 3, 'Confirmed');
-- How to check all available flights between two cities?
SELECT flight_id, flight_number, source, destination, departure_time, price
FROM Flights
WHERE source = 'Delhi' AND destination = 'Mumbai';


-- How to check available seats for a flight?
SELECT seat_id, seat_number
FROM Seats
WHERE flight_id = 1 AND is_booked = 0;

-- How to cancel a booking?

UPDATE Bookings
SET status = 'Cancelled'
WHERE booking_id = 2;

-- How to see the booking summary for a customer?
SELECT b.booking_id, c.name, f.flight_number, s.seat_number, b.status
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Flights f ON b.flight_id = f.flight_id
JOIN Seats s ON b.seat_id = s.seat_id
WHERE b.customer_id = 2;


-- How to see the total bookings per flight?
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_number;

-- How to view estimated revenue per flight

SELECT * FROM flight_summary;
-- How to add a new customer
INSERT INTO Customer (name, email, phone)
VALUES ('John Doe', 'john@example.com', '9876543210');

-- How to add a new flight?
INSERT INTO Flights (flight_number, source, destination, departure_time, arrival_time, price)
VALUES ('AI104', 'Delhi', 'Chennai', '2025-10-20 09:00:00', '2025-10-20 12:30:00', 5000.00);


-- How to check which seats are booked for a flight
SELECT seat_id, seat_number
FROM Seats
WHERE flight_id = 1 AND is_booked = 1;

