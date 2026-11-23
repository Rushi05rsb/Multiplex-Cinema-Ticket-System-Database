/*
  MULTIPLEX CINEMA TICKET & SHOW SYSTEM
  MySQL 8.0+ script for MySQL Workbench

  IMPORTANT:
  This script drops and recreates the Multiplex_Cinema database so it can
  be executed from a clean state. Existing data in this database will be deleted.
  Run the script once from top to bottom. Do not run the price UPDATE repeatedly
  unless you reset/recreate the database first.
*/

DROP DATABASE IF EXISTS Multiplex_Cinema;
CREATE DATABASE Multiplex_Cinema;
USE Multiplex_Cinema;

-- =========================================================
-- TASK 1 & 2: TABLES, PRIMARY KEYS, FOREIGN KEYS AND RULES
-- =========================================================

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15)
) ENGINE = InnoDB;

CREATE TABLE Movies (
    Movie_ID INT PRIMARY KEY AUTO_INCREMENT,
    Movie_Title VARCHAR(150) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Language VARCHAR(40) NOT NULL,
    Duration_Minutes INT NOT NULL,
    Rating VARCHAR(10),
    CONSTRAINT chk_movie_duration CHECK (Duration_Minutes > 0)
) ENGINE = InnoDB;

CREATE TABLE Screens (
    Screen_ID INT PRIMARY KEY AUTO_INCREMENT,
    Screen_Name VARCHAR(50) NOT NULL UNIQUE,
    Seating_Capacity INT NOT NULL,
    CONSTRAINT chk_screen_capacity CHECK (Seating_Capacity > 0)
) ENGINE = InnoDB;

CREATE TABLE Shows (
    Show_ID INT PRIMARY KEY AUTO_INCREMENT,
    Movie_ID INT NOT NULL,
    Screen_ID INT NOT NULL,
    Show_Date DATE NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    CONSTRAINT fk_shows_movie
        FOREIGN KEY (Movie_ID) REFERENCES Movies(Movie_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_shows_screen
        FOREIGN KEY (Screen_ID) REFERENCES Screens(Screen_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_screen_show_start UNIQUE (Screen_ID, Show_Date, Start_Time),
    CONSTRAINT chk_show_time CHECK (End_Time > Start_Time)
) ENGINE = InnoDB;

CREATE TABLE Tickets (
    Ticket_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Show_ID INT NOT NULL,
    Seat_Code VARCHAR(10) NOT NULL,
    Seat_Tier ENUM('Silver', 'Gold', 'Recliner') NOT NULL,
    Ticket_Price DECIMAL(8,2) NOT NULL,
    Booking_Time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tickets_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tickets_show
        FOREIGN KEY (Show_ID) REFERENCES Shows(Show_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_show_seat UNIQUE (Show_ID, Seat_Code),
    CONSTRAINT chk_ticket_price CHECK (Ticket_Price >= 0)
) ENGINE = InnoDB;

-- =========================================================
-- TASK 3: SAMPLE DATA (5 ROWS IN EACH TABLE)
-- All show dates below use 24 November 2026.
-- Movie 5 has a scheduled show but no ticket bookings.
-- =========================================================

INSERT INTO Customers (Customer_Name, Email, Phone) VALUES
('Aarav Patil', 'aarav.patil@example.com', '9876500001'),
('Ananya Shah', 'ananya.shah@example.com', '9876500002'),
('Vivaan Kulkarni', 'vivaan.k@example.com', '9876500003'),
('Isha Deshmukh', 'isha.d@example.com', '9876500004'),
('Kabir Joshi', 'kabir.j@example.com', '9876500005');

INSERT INTO Movies (Movie_Title, Genre, Language, Duration_Minutes, Rating) VALUES
('The Last Kingdom', 'Action', 'Hindi', 145, 'UA'),
('Ocean of Dreams', 'Romance', 'English', 128, 'U'),
('Mystery House', 'Thriller', 'Marathi', 132, 'UA'),
('Laugh Out Loud', 'Comedy', 'Hindi', 118, 'U'),
('The Silent Planet', 'Science Fiction', 'Tamil', 150, 'UA');

INSERT INTO Screens (Screen_Name, Seating_Capacity) VALUES
('Screen 1', 120),
('Screen 2', 100),
('Screen 3', 90),
('Screen 4', 150),
('Screen 5', 80);

INSERT INTO Shows (Movie_ID, Screen_ID, Show_Date, Start_Time, End_Time) VALUES
(1, 1, '2026-11-24', '10:00:00', '12:25:00'),
(2, 2, '2026-11-24', '13:00:00', '15:08:00'),
(3, 3, '2026-11-24', '16:00:00', '18:12:00'),
(4, 4, '2026-11-24', '19:00:00', '20:58:00'),
(5, 5, '2026-11-24', '11:00:00', '13:30:00');

INSERT INTO Tickets (Customer_ID, Show_ID, Seat_Code, Seat_Tier, Ticket_Price) VALUES
(1, 1, 'B12', 'Silver',   400.00),
(2, 1, 'B13', 'Gold',     550.00),
(3, 1, 'C10', 'Recliner', 700.00),
(4, 1, 'C11', 'Gold',     550.00),
(5, 1, 'D05', 'Recliner', 700.00);

-- =========================================================
-- TASK 3: REQUIRED FIVE SQL QUERIES
-- =========================================================

-- QUERY 1: SHOW BOOKINGS
-- Lists the shows on the given date. LEFT JOIN also displays shows
-- with no bookings; customer and seat fields will be NULL for those shows.
SELECT
    s.Show_ID,
    c.Customer_Name,
    m.Movie_Title,
    sc.Screen_Name,
    t.Seat_Code,
    s.Show_Date,
    s.Start_Time
FROM Shows AS s
JOIN Movies AS m ON m.Movie_ID = s.Movie_ID
JOIN Screens AS sc ON sc.Screen_ID = s.Screen_ID
LEFT JOIN Tickets AS t ON t.Show_ID = s.Show_ID
LEFT JOIN Customers AS c ON c.Customer_ID = t.Customer_ID
WHERE s.Show_Date = '2026-11-24'
ORDER BY s.Start_Time, t.Seat_Code;

-- QUERY 2: ZERO-SALE MOVIES
-- Finds movies for which no ticket has been booked for any show.
SELECT
    m.Movie_ID,
    m.Movie_Title
FROM Movies AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM Shows AS s
    INNER JOIN Tickets AS t ON t.Show_ID = s.Show_ID
    WHERE s.Movie_ID = m.Movie_ID
);

-- QUERY 3: BOX-OFFICE COLLECTION
-- Shows ticket count and collection for movies earning at least Rs. 2,000.
SELECT
    m.Movie_Title,
    COUNT(t.Ticket_ID) AS Total_Tickets_Sold,
    SUM(t.Ticket_Price) AS Total_Collection
FROM Movies AS m
INNER JOIN Shows AS s ON s.Movie_ID = m.Movie_ID
INNER JOIN Tickets AS t ON t.Show_ID = s.Show_ID
GROUP BY m.Movie_ID, m.Movie_Title
HAVING SUM(t.Ticket_Price) >= 2000.00;

-- QUERY 4: PREMIUM TICKETS
-- Finds tickets priced above the average price of all booked tickets.
SELECT
    Ticket_ID,
    Show_ID,
    Seat_Code,
    Seat_Tier,
    Ticket_Price
FROM Tickets
WHERE Ticket_Price > (
    SELECT AVG(Ticket_Price)
    FROM Tickets
);

-- QUERY 5: UPDATE & VERIFY
-- Reduce prices by Rs. 50 for tickets belonging to shows before 12 noon
-- on 24 November 2026. Safe update mode is disabled only for this UPDATE
-- and is immediately turned back on afterwards.
SET SQL_SAFE_UPDATES = 0;

UPDATE Tickets AS t
INNER JOIN Shows AS s ON s.Show_ID = t.Show_ID
SET t.Ticket_Price = t.Ticket_Price - 50.00
WHERE s.Show_Date = '2026-11-24'
  AND s.Start_Time < '12:00:00'
  AND t.Ticket_Price >= 50.00;

SET SQL_SAFE_UPDATES = 1;

-- SELECT immediately after UPDATE to verify the changed rows.
SELECT
    t.Ticket_ID,
    t.Seat_Code,
    t.Seat_Tier,
    t.Ticket_Price,
    s.Show_Date,
    s.Start_Time
FROM Tickets AS t
INNER JOIN Shows AS s ON s.Show_ID = t.Show_ID
WHERE s.Show_Date = '2026-11-24'
  AND s.Start_Time < '12:00:00'
ORDER BY t.Seat_Code;

-- =========================================================
-- TASK 4: TWO INVALID INSERT TEST CASES (EXPECTED TO FAIL)
-- Keep these statements commented while running the full script.
-- Uncomment and execute each test separately after the main script.
-- =========================================================

-- TEST 1: Expected to fail because B12 already exists for Show_ID 1.
-- UNIQUE (Show_ID, Seat_Code) prevents the same seat being booked twice
-- for one show.
-- INSERT INTO Tickets (Customer_ID, Show_ID, Seat_Code, Seat_Tier, Ticket_Price)
-- VALUES (1, 1, 'B12', 'Silver', 400.00);

-- TEST 2: Expected to fail because ticket price cannot be negative.
-- CHECK (Ticket_Price >= 0) rejects this value.
-- INSERT INTO Tickets (Customer_ID, Show_ID, Seat_Code, Seat_Tier, Ticket_Price)
-- VALUES (1, 2, 'Z99', 'Silver', -100.00);

-- OPTIONAL: Check the row counts in all five tables.
SELECT 'Customers' AS Table_Name, COUNT(*) AS Total_Records FROM Customers
UNION ALL
SELECT 'Movies', COUNT(*) FROM Movies
UNION ALL
SELECT 'Screens', COUNT(*) FROM Screens
UNION ALL
SELECT 'Shows', COUNT(*) FROM Shows
UNION ALL
SELECT 'Tickets', COUNT(*) FROM Tickets;
