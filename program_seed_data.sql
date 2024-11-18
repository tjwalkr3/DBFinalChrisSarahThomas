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
	constraint fk_passenger_id foreign key (passenger_id) references airline_booking2.passenger(id),
	constraint fk_scheduled_flight_id foreign key (scheduled_flight_id) references airline_booking2.scheduled_flight(id)	
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
	seat_type_id int not null,
	printed_boarding_pass_at timestamp,
	seat_number int,
	passenger_id int,
	constraint fk_ab_reservation_id foreign key (reservation_id) references airline_booking2.reservation(id),
	constraint fk_ab_seat_type_id foreign key (seat_type_id) references airline_booking2.seat_type(id)
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

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE airline_booking2.scheduled_flight
ADD CONSTRAINT prevent_overlapping_flights
EXCLUDE USING gist
(
    plane_id WITH =,   
    tsrange(departure_time, arrival_time, '[)') WITH &&
)
WHERE (departure_time IS NOT NULL AND arrival_time IS NOT NULL);

INSERT INTO airline_booking2.plane_type (plane_name) values 
	('Boeing 737-200'),
    ('Boeing 737-220'),
    ('Boeing 747-400'),
    ('Boeing 757-020'),
    ('Airbus A300-03');
	
INSERT INTO airline_booking2.seat_type (seat_type) VALUES
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
