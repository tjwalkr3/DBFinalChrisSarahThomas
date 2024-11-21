drop schema if exists airline_booking2 cascade;
create schema airline_booking2;

---------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------

create table airline_booking2.passenger (
	id int primary key generated always as identity,
	passenger_name varchar(100) not null, 
	passport_id varchar(9),
	phone varchar(15) not null,
	email varchar(200), 
	address varchar(200) not null
);

create table airline_booking2.seat_type (
	id int primary key generated always as identity,
	seat_type varchar(15) unique not null
);

create table airline_booking2.plane_type (
	id int primary key generated always as identity,
	plane_name varchar(30) unique not null
);

create table airline_booking2.plane_type_seat_type (
	id int primary key generated always as identity,
	plane_type_id int not null references airline_booking2.plane_type(id),
	seat_type_id int not null references airline_booking2.seat_type(id),
	quantity int not null
);

create table airline_booking2.plane (
	id int primary key generated always as identity,
	plane_type_id int not null references airline_booking2.plane_type(id)
);

create table airline_booking2.airport (
	id int primary key generated always as identity,
	code varchar(3) not null,
	address varchar(200) not null
);

create table airline_booking2.overbooking_rate (
	id int primary key generated always as identity,
	rate decimal(5,2) not null unique check(rate > 0)
); 

create table airline_booking2.scheduled_flight (
	id int primary key generated always as identity,
	departure_time timestamp not null,
	arrival_time timestamp not null check(arrival_time > departure_time),
	plane_id int not null references airline_booking2.plane(id),
	departure_airport_id int not null references airline_booking2.airport(id),
	arrival_airport_id int not null references airline_booking2.airport(id) check(arrival_airport_id != departure_airport_id),
	overbooking_id int not null references airline_booking2.overbooking_rate(id)
);

create table airline_booking2.reservation (
	id int primary key generated always as identity,
	passenger_id int not null,
	scheduled_flight_id int not null,
	ticket_cost decimal(5,2) not null check(ticket_cost > 0),
	seat_type_id int not null,
	seat_count int not null,
	constraint fk_passenger_id foreign key (passenger_id) references airline_booking2.passenger(id),
	constraint fk_scheduled_flight_id foreign key (scheduled_flight_id) references airline_booking2.scheduled_flight(id),
	constraint fk_seat_type_id foreign key (seat_type_id) references airline_booking2.seat_type(id)
);

create table airline_booking2.payment (
	id int primary key generated always as identity,
	reservation_id int not null, 
	amount decimal(5,2) not null,
	constraint fk_reservation_id foreign key (reservation_id) references airline_booking2.reservation(id)
);

create table airline_booking2.flight_history (
	id int primary key generated always as identity,
	scheduled_flight_id int not null references airline_booking2.scheduled_flight(id),
	plane_id int not null references airline_booking2.plane(id),
	actual_departure_time timestamp,
	actual_arrival_time timestamp check(actual_arrival_time > actual_departure_time)
);

create table airline_booking2.seat (
	id int primary key generated always as identity,
	reservation_id int not null,
	printed_boarding_pass_at timestamp,
	seat_number int,
	passenger_id int,
	constraint fk_ab_reservation_id foreign key (reservation_id) references airline_booking2.reservation(id)
);

create table airline_booking2.concession_purchase (
	id int primary key generated always as identity,
	payment_id int not null,
	seat_id int not null,
	constraint cp_payment_id foreign key (payment_id) references airline_booking2.payment(id),
	constraint cp_seat_id foreign key (seat_id) references airline_booking2.seat(id)
);

create table airline_booking2.product (
	id int primary key generated always as identity,
	concession_name varchar(200) unique not null,
	price decimal(5,2) not null check(price > 0)
);

create table airline_booking2.concession_purchase_product (
	id int primary key generated always as identity,
	product_id int not null, 
	concession_purchase_id int not null,
	quantity int not null,
	constraint fk_product_id foreign key (product_id) references airline_booking2.product(id),
	constraint fk_concession_purchase_id foreign key (concession_purchase_id) references airline_booking2.concession_purchase(id)
);

-- CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ALTER TABLE airline_booking2.scheduled_flight
-- ADD CONSTRAINT prevent_overlapping_flights
-- EXCLUDE USING gist
-- (
--     plane_id WITH =,   
--     tsrange(departure_time, arrival_time, '[)') WITH &&
-- )
-- WHERE (departure_time IS NOT NULL AND arrival_time IS NOT NULL);

---------------------------------------------------------------
-- Sample Data
---------------------------------------------------------------

INSERT INTO airline_booking2.plane_type (plane_name) values 
	('Boeing 737-200'),
    ('Boeing 737-220'),
    ('Boeing 747-400'),
    ('Boeing 757-020'),
    ('Airbus A300-03');
	
INSERT INTO airline_booking2.seat_type (seat_type) values
	('coach'),
	('business class'),
	('first class');
	
INSERT INTO airline_booking2.overbooking_rate (rate) VALUES
    (2.25);
	
INSERT INTO airline_booking2.airport (code, address) VALUES
    ('JFK', 'Queens, NY 11430, US'),
    ('LAX', '1 World Way, Los Angeles, CA 90045, US'),
    ('SEA', '17801 International Blvd, Pmb 68727, Seattle WA 98158, US'),
    ('ORD', '10000 W Balmoral Ave, Chicago IL 60666, US'),
    ('MDW', '5700 S Cicero Ave, Chicago IL 60638, US'),
    ('SFO', 'San Francisco, CA 94128, US'),
    ('SLC', 'W Terminal Dr, Salt Lake City, UT 84122, US'),
    ('DEN', '8500 Pena Blvd. Denver, CO 80249, US'),
    ('AGS', '1501 Aviation Way, Augusta, GA 30906, US'),
    ('ANC', '5000 W International Airport Rd, Anchorage, AK 99502, US');

INSERT INTO airline_booking2.plane_type_seat_type (plane_type_id, seat_type_id, quantity) VALUES
    (1, 1, 120),
    (2, 1, 165),
    (2, 2, 14),
    (3, 1, 220),
    (3, 2, 21),
    (3, 3, 6),
    (4, 1, 185),
    (4, 2, 18),
    (4, 3, 8),
    (5, 1, 170),
    (5, 2, 12),
    (5, 3, 6);

INSERT INTO airline_booking2.plane (plane_type_id) VALUES
    (1), -- 5 Boeing 737-200 planes
    (1),
    (1),
    (1),
    (1),
    (2), -- 5 Boeing 737-220 planes
    (2),
    (2),
    (2),
    (2),
    (3), -- 5 Boeing 747-400 planes
    (3),
    (3),
    (3),
    (3),
    (4), -- 3 Boeing 757-020 planes
    (4),
    (4),
    (5), -- 2 Airbus A300-03 planes
    (5);

INSERT INTO airline_booking2.scheduled_flight (departure_time,arrival_time,plane_id,departure_airport_id,arrival_airport_id,overbooking_id) VALUES
	 ('2024-08-16 04:30:00','2024-08-16 06:35:00',1,7,2,1),
	 ('2024-08-16 06:50:00','2024-08-16 13:00:00',1,2,1,1),
	 ('2024-08-16 13:15:00','2024-08-16 19:30:00',1,1,3,1),
	 ('2024-08-21 07:00:00','2024-08-21 09:00:00',1,2,3,1),
	 ('2024-08-22 04:30:00','2024-08-22 06:30:00',2,3,5,1),
	 ('2024-08-16 07:30:00','2024-08-16 09:30:00',2,10,9,1),
	 ('2024-08-16 09:45:00','2024-08-16 12:00:00',2,9,5,1),
	 ('2024-08-16 12:15:00','2024-08-16 14:15:00',2,5,6,1),
	 ('2024-08-21 09:45:00','2024-08-21 11:45:00',1,3,2,1);

INSERT INTO airline_booking2.flight_history (scheduled_flight_id,plane_id,actual_departure_time,actual_arrival_time) VALUES
	 (1,1,'2024-08-16 04:40:00','2024-08-16 06:45:00'),
	 (2,1,'2024-08-16 07:20:00','2024-08-16 13:20:00'),
	 (4,2,'2024-08-16 07:40:00','2024-08-16 09:40:00'),
	 (5,2,'2024-08-16 10:05:00','2024-08-16 12:20:00'),
	 (6,2,NULL,NULL);
   
INSERT INTO airline_booking2.passenger (passenger_name, passport_id, phone, email, address) VALUES 
    ('Thomas Jones', '123456789', '801-420-6666', 'thomas@gmail.com', '123 W 456 S, Seattle, WA'),
    ('Sarah Martin', '987654321', '123-456-7890', 'sarah@gmail.com', '321 W 654 S, Salt Lake City, UT'),
    ('Chris Young', '123789456', '666-420-6969', 'chris@gmail.com', '222 W 222 S, Denver, CO'),
    ('Taft Allen', '111222333', '420-666-6969', 'taft@gmail.com', '111 W 111 S, Los Angeles, CA'),
    ('Ricardo Ruiz', '333222111', '420-111-2222', 'ricardo@gmail.com', '420 Ave 666, San Francisco, CA'),
    ('Cody Howell', '444555666', '801-420-7777', 'cody@gmail.com', '121 W 323 S, Chicago, IL'),
    ('Nathan Howell', '777888999', '801-420-8888', 'nathan@gmail.com', '333 W 444 S, Layton, UT');
		
insert into airline_booking2.reservation 
(passenger_id, scheduled_flight_id, ticket_cost, seat_type_id, seat_count)
values (1, 1, 200.00, 1, 1),
	(2, 1, 200.00, 1, 1),
	(3, 2, 150.00, 1, 1),
	(6, 5, 200.00, 1, 1),
	(5, 5, 150.00, 1, 1),
	(7, 6, 200.00, 1, 1),
	(1, 7, 200.00, 1, 1),
	(2, 7, 200.00, 1, 1),
	(5, 8, 150.00, 1, 1),
	(7, 9, 200.00, 1, 1),
	(6, 9, 200.00, 1, 1);

INSERT INTO airline_booking2.seat (reservation_id, printed_boarding_pass_at, seat_number, passenger_id) VALUES 
    (1, '2024-08-16 02:30:00', 1, 1),
    (1, '2024-08-16 02:31:00', 2, 4),
    (2, '2024-08-16 04:53:00', 3, 2),
    (3, '2024-08-16 05:31:00', 20, 3),
    (4, '2024-08-16 02:00:00', 30, 6),
    (5, DEFAULT, DEFAULT, DEFAULT),
    (6, '2024-08-16 04:30:00', 31, 7);
		
INSERT INTO airline_booking2.payment
(reservation_id, amount)
VALUES (1, 400.00),
	(1, 3.99),
	(1, 5.78),
	(2, 200.00),
	(2, 1.99),
	(3, 150.00),
	(4, 200.00),
	(5, 150.00),
	(6, 200.00),
	(6, -200.00),
	(7, 200.00),
	(8, 200.00),
	(9, 150.00),
	(10, 200.00),
	(11, 200.00);

insert into airline_booking2.product (concession_name, price) values
	('Pillow', 8.16),
	('Blanket', 6.12),
	('Headphones', 20.99),
	('Candy bar', 3.99),
	('Fountain drink', 2.89),
	('Chewing gum', 1.99);

---------------------------------------------------------------
-- Functions, Procedures, and Triggers
---------------------------------------------------------------

-- Enforce the overbooking limit by getting the plane capacities and comparing them with the number of reservations
create or replace function enforce_overbooking_limit() returns trigger
language plpgsql
as $$
declare
    plane_id int;
    overbooking_rate numeric(5,2);
    total_plane_seats int;
    total_first_class_plane_seats int;
    total_business_class_plane_seats int;
    total_seats_booked int;
    first_class_seats_booked int;
    business_class_seats_booked int;
    max_seat_bookings int;
    overbooking_error_msg varchar(150) := 'The reservation cannot be made because it would exceed this scheduled flight''s overbooking rate.';
begin
    -- Get the plane_id for the scheduled flight
    select sf.plane_id into plane_id
    from airline_booking2.scheduled_flight sf
    where sf.id = new.scheduled_flight_id;

    -- Get the overbooking rate for the scheduled flight
    select o.rate into overbooking_rate 
    from airline_booking2.scheduled_flight sf
    inner join airline_booking2.overbooking_rate o on o.id = sf.overbooking_id
    where sf.id = new.scheduled_flight_id;

    -- Calculate total seats for the plane
    select sum(ptst.quantity) into total_plane_seats
    from airline_booking2.plane p
    inner join airline_booking2.plane_type pt on p.plane_type_id = pt.id
    inner join airline_booking2.plane_type_seat_type ptst on ptst.plane_type_id = pt.id
    where p.id = plane_id;

    -- Calculate total first-class seats for the plane
    select sum(ptst.quantity) into total_first_class_plane_seats
    from airline_booking2.plane p
    inner join airline_booking2.plane_type pt on p.plane_type_id = pt.id
    inner join airline_booking2.plane_type_seat_type ptst on ptst.plane_type_id = pt.id
    where p.id = plane_id and ptst.seat_type_id = 3; -- First class

    -- Calculate total business-class seats for the plane
    select sum(ptst.quantity) into total_business_class_plane_seats
    from airline_booking2.plane p
    inner join airline_booking2.plane_type pt on p.plane_type_id = pt.id
    inner join airline_booking2.plane_type_seat_type ptst on ptst.plane_type_id = pt.id
    where p.id = plane_id and ptst.seat_type_id = 2; -- Business class

    -- Calculate total seats booked for the scheduled flight
    select coalesce(sum(r.seat_count), 0) into total_seats_booked
    from airline_booking2.reservation r
    where r.scheduled_flight_id = new.scheduled_flight_id;

    -- Calculate total first-class seats booked for the scheduled flight
    select coalesce(sum(r.seat_count), 0) into first_class_seats_booked
    from airline_booking2.reservation r
    where r.scheduled_flight_id = new.scheduled_flight_id and r.seat_type_id = 3;

    -- Calculate total business-class seats booked for the scheduled flight
    select coalesce(sum(r.seat_count), 0) into business_class_seats_booked
    from airline_booking2.reservation r
    where r.scheduled_flight_id = new.scheduled_flight_id and r.seat_type_id = 2;

    -- Calculate the maximum allowed seat bookings (including overbooking)
    select total_plane_seats + ceiling(overbooking_rate * total_plane_seats) into max_seat_bookings;

    -- Validate overbooking limits
    if new.seat_type_id = 1 then -- Coach seats
        if total_seats_booked + new.seat_count > max_seat_bookings then
            raise exception '%', overbooking_error_msg;
        end if;
    elsif new.seat_type_id = 2 then -- Business class seats
        if business_class_seats_booked + new.seat_count > total_business_class_plane_seats then
            raise exception '%', overbooking_error_msg;
        end if;
    elsif new.seat_type_id = 3 then -- First class seats
        if first_class_seats_booked + new.seat_count > total_first_class_plane_seats then
            raise exception '%', overbooking_error_msg;
        end if;
    end if;

    return new;
end;
$$;

create or replace trigger check_overbooking_limit
before insert on airline_booking2.reservation for each row
execute function enforce_overbooking_limit();

-- Flight performance function
-- Calculates percentages based on the flights that have been canceled
CREATE OR REPLACE FUNCTION flight_performance_efficiency() 
RETURNS TABLE(percent_flights_on_time INT, percent_flights_canceled INT) AS $$
BEGIN
    RETURN QUERY
    WITH flight_counts AS (
        SELECT 
            COUNT(*) AS total_flights,
            SUM(CASE 
                    WHEN fh.actual_departure_time IS NULL AND fh.actual_arrival_time IS NULL THEN 1
                    ELSE 0
                END) AS canceled_flights,
            SUM(CASE 
                    WHEN fh.actual_departure_time IS NOT NULL AND fh.actual_arrival_time IS NOT NULL THEN 1
                    ELSE 0
                END) AS on_time_flights
        FROM airline_booking2.flight_history fh
    )
    SELECT 
        (COALESCE(on_time_flights, 0) * 100.0 / COALESCE(total_flights, 1))::INT AS percent_flights_on_time,
        (COALESCE(canceled_flights, 0) * 100.0 / COALESCE(total_flights, 1))::INT AS percent_flights_canceled
    FROM flight_counts;
END;
$$ LANGUAGE plpgsql;

-- flight continuity procedure
-- makes sure planes aren't teleporting between flights
CREATE OR REPLACE PROCEDURE flight_continuity ()
LANGUAGE plpgsql
AS $$
DECLARE
    current_row RECORD;
    -- Variable to hold each row during iteration
    last_row RECORD;
    -- Variable to store the last row
BEGIN
    FOR current_row IN
    SELECT
        id,
        departure_airport_id,
        arrival_airport_id,
        plane_id
    FROM
        airline_booking2.scheduled_flight
    ORDER BY
        plane_id ASC,
        departure_time ASC -- Ensure rows are processed in a defined order
        LOOP
            -- If last_row is not null, perform the comparison
            IF last_row IS NOT NULL THEN
                IF last_row.arrival_airport_id = current_row.departure_airport_id THEN
                    --RAISE NOTICE 'Row continuity check passed: Plane ID=%, Last Arrival=%, Current Departure=%', last_row.plane_id, last_row.arrival_airport_id, current_row.departure_airport_id;
                ELSIF last_row.plane_id != current_row.plane_id THEN
                    --RAISE NOTICE 'Row continuity check passed: new plane: Plane ID=%, Departure=%', last_row.plane_id, current_row.departure_airport_id;
                ELSE
                    RAISE WARNING 'Row continuity check failed: Flight ID=%, Last Arrival=%, Current Departure=%', current_row.id, last_row.arrival_airport_id, current_row.departure_airport_id;
                END IF;
            END IF;
            -- Update last_row to hold the current_row for the next iteration
            last_row := current_row;
        END LOOP;
END;
$$;

-- scheduled_flight insert procedure
-- make sure that the departure airport of the flight being inserted is the same as the arrival airport of the last flight
CREATE OR REPLACE PROCEDURE insert_scheduled_flight(new_flight RECORD)
LANGUAGE plpgsql AS $$
DECLARE
    last_flight RECORD; -- To hold the most recent flight for the plane
BEGIN
    -- Fetch the most recent flight for the given plane
    SELECT *
    INTO last_flight
    FROM airline_booking2.scheduled_flight
    WHERE plane_id = new_flight.plane_id
    ORDER BY departure_time DESC
    LIMIT 1;

    -- Perform the continuity check if a previous flight exists
    IF last_flight IS NOT NULL THEN
        IF last_flight.arrival_airport_id != new_flight.departure_airport_id THEN
            RAISE EXCEPTION 'Continuity check failed: Last arrival airport (ID=%) does not match current departure airport (ID=%)',
                            last_flight.arrival_airport_id, new_flight.departure_airport_id;
        END IF;
    END IF;

    -- Insert the new scheduled flight into the database
    INSERT INTO airline_booking2.scheduled_flight (
        departure_time,
        arrival_time,
        plane_id,
        departure_airport_id,
        arrival_airport_id,
        overbooking_id
    )
    VALUES (
        new_flight.departure_time,
        new_flight.arrival_time,
        new_flight.plane_id,
        new_flight.departure_airport_id,
        new_flight.arrival_airport_id,
        new_flight.overbooking_id
    );
END;
$$;

-- Create a type for inserting into scheduled_flight using the insert_scheduled_flight method
drop type if exists scheduled_flight_type;
CREATE TYPE scheduled_flight_type AS (
    departure_time timestamp,
    arrival_time timestamp,
    plane_id int,
    departure_airport_id int,
    arrival_airport_id int,
    overbooking_id int
);

---------------------------------------------------------------
-- Views
---------------------------------------------------------------

create view plane_total_flight_time as
	select
		p.id plane_id,
		sum(age(fh.actual_arrival_time, fh.actual_departure_time)) total_hours_flight_time
	from
	airline_booking2.flight_history fh
	inner join airline_booking2.plane p on (p.id = fh.plane_id)
	where (fh.actual_departure_time is not null and fh.actual_arrival_time is not null)
	group by p.id
	order by p.id;

create view customer_flight_expenses as
	select 
		p.id passenger_id,
		p.passenger_name,
		sf.departure_time::date flight_departure_date,
		sf.plane_id,
		ad.code departure_airport_code,
		aa.code arrival_airport_code,
		sum(pay.amount) amount_spent
	from 
	airline_booking2.payment pay
	inner join airline_booking2.reservation r on (pay.reservation_id = r.id)
	inner join airline_booking2.scheduled_flight sf on (sf.id = r.scheduled_flight_id)
	inner join airline_booking2.passenger p on (p.id = r.passenger_id)
	inner join airline_booking2.airport ad on (ad.id = sf.departure_airport_id)
	inner join airline_booking2.airport aa on (aa.id = sf.arrival_airport_id)
	group by p.id, p.passenger_name, sf.plane_id, flight_departure_date, departure_airport_code, arrival_airport_code
	order by passenger_name asc;

