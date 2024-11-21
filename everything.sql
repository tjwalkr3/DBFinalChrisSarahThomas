drop schema if exists airline_booking2 cascade;
create schema airline_booking2;

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
		
insert into airline_booking2.product (concession_name, price) values
	('Pillow', 8.16),
	('Blanket', 6.12),
	('Headphones', 20.99),
	('Candy bar', 3.99),
	('Fountain drink', 2.89),
	('Chewing gum', 1.99);

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
-- Functions and Procedures
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

-- flight performance function
-- calculates percentages based on the flights that have been canceled
create or replace function flight_performance_efficiency() returns table(percent_flights_on_time int, percent_flights_canceled int) as $$
	begin
	return query with flight_counts as (
	select 
		count(*) as total_flights,
		sum(case 
				when fh.actual_departure_time is null and fh.actual_arrival_time is null then 1 
				else 0 
			end
		) as canceled_flights,
		sum(case 
				when fh.actual_departure_time is not null and fh.actual_arrival_time is not null then 1  
				else 0 
			end
		) as on_time_flights
	from airline_booking2.flight_history fh
	)
	select 
		(coalesce(on_time_flights, 0) * 100.0 / coalesce(total_flights, 1))::int as percent_flights_on_time,
		(coalesce(canceled_flights, 0) * 100.0 / coalesce(total_flights, 1))::int as percent_flights_canceled
	from flight_counts;
	end;
$$ language plpgsql;

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
CREATE TYPE scheduled_flight_type AS (
    departure_time timestamp,
    arrival_time timestamp,
    plane_id int,
    departure_airport_id int,
    arrival_airport_id int,
    overbooking_id int
);

