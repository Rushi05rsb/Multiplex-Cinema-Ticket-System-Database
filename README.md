# Multiplex Cinema Ticket & Show System

A relational database project developed using **MySQL** and **MySQL Workbench** for managing multiplex customers, movies, screens, show schedules, and ticket bookings.

## Project Overview

The database is named `Multiplex_Cinema` and contains five related tables. Primary keys identify each record, while foreign keys connect customers, movies, screens, shows, and tickets. The design also applies constraints to prevent invalid or duplicate booking data.

## Repository Structure

```text
Multiplex-Cinema-Ticket-System-Database/
│
├── ER-Diagram/
│   └── Cinema_Database_ERD.png
│
├── SQL Queries/
│   └── SQL_Multiplex_Cinema_Database.sql
│
└── README.md
```

## Database Tables

| Table | Purpose | Primary Key | Foreign Keys |
|---|---|---|---|
| Customers | Stores customer name, email, and phone number. | Customer_ID | — |
| Movies | Stores movie title, genre, language, duration, and rating. | Movie_ID | — |
| Screens | Stores screen name and seating capacity. | Screen_ID | — |
| Shows | Stores movie, screen, date, and show timings. | Show_ID | Movie_ID, Screen_ID |
| Tickets | Stores customer bookings, seat details, ticket tier, price, and booking time. | Ticket_ID | Customer_ID, Show_ID |

## Relationships and Data Rules

- One movie can be scheduled for multiple shows.
- One screen can host multiple shows at different dates or start times.
- One customer can book multiple tickets.
- One show can have multiple tickets, but a seat can only be booked once for a particular show.
- A ticket must reference an existing customer and show.
- Ticket tiers are `Silver`, `Gold`, and `Recliner`.

The SQL schema includes these important constraints:

- Primary keys and foreign keys for relational integrity.
- Unique customer email and screen name.
- `UNIQUE (Show_ID, Seat_Code)` to prevent duplicate seat bookings for the same show.
- `CHECK` constraints for positive movie duration, positive screen capacity, valid show time order, and non-negative ticket price.
- `ON DELETE RESTRICT` for movie, screen, and customer references where dependent records exist; `ON DELETE CASCADE` from Shows to Tickets.

## Requirements

- MySQL Server **8.0.16 or newer** (for enforced `CHECK` constraints).
- MySQL Workbench or another MySQL client.

## How to Run the SQL Script

1. Clone or download this repository.
2. Open MySQL Workbench and connect to your local MySQL Server.
3. Select **File → Open SQL Script**.
4. Open `SQL Queries/SQL_Multiplex_Cinema_Database.sql`.
5. Execute the script from top to bottom using the lightning-bolt **Execute** button.
6. Refresh the **SCHEMAS** panel. The `Multiplex_Cinema` database should be visible.

> **Important:** The script begins with `DROP DATABASE IF EXISTS Multiplex_Cinema;`. Running it will delete and recreate the existing `Multiplex_Cinema` database, including any data already stored in it. Back up any data you need before running the script. Run it once from a clean state. The ticket-price update is applied by the script; do not run that update repeatedly unless you recreate/reset the database first.

## Sample Data

The script inserts five sample records into each of the five tables:

- 5 customers
- 5 movies
- 5 screens
- 5 scheduled shows
- 5 ticket bookings

All sample shows are dated **24 November 2026**. The fifth movie has a scheduled show but no ticket bookings, allowing the zero-sale-movie query to demonstrate its result.

## SQL Tasks / Queries

The SQL script demonstrates the following operations:

1. **Show bookings:** Lists show details and any customer/seat bookings for the selected date. `LEFT JOIN` keeps shows with no bookings in the result.
2. **Zero-sale movies:** Finds movies for which no tickets have been booked for any show.
3. **Box-office collection:** Calculates tickets sold and total collection per movie, showing movies with collection of at least ₹2,000.
4. **Premium tickets:** Finds tickets priced above the average ticket price.
5. **Update and verify:** Reduces ticket prices by ₹50 for tickets belonging to shows starting before 12:00 PM on 24 November 2026, then displays the updated ticket rows.

The update temporarily sets `SQL_SAFE_UPDATES` to `0` for that statement and turns it back on immediately afterwards.

## Constraint Testing

The script includes two commented-out test statements under **Task 4**. They are intentionally not executed as part of the full script:

- A duplicate seat booking for the same show, expected to fail because of `UNIQUE (Show_ID, Seat_Code)`.
- A ticket with a negative price, expected to fail because of `CHECK (Ticket_Price >= 0)`.

To test these constraints, uncomment and execute each test statement separately after the main script has completed. The expected error demonstrates that the corresponding rule is enforced.

## ER Diagram

The entity-relationship diagram is available here:

`ER-Diagram/Cinema_Database_ERD.png`

## Author / Academic Use

Prepared as an MCA database assignment for **Applied Database Management Systems / RDBMS & SQL** using MySQL Workbench.
