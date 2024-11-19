
drop schema if exists airline_booking cascade;
create schema airline_booking;

create table airline_booking.passenger (
	id int primary key generated always as identity,
	passenger_name varchar(100) not null, 
	passport_id varchar(9),
	phone varchar(15) not null,
	email varchar(200), 
	address varchar(200) not null
);

create table airline_booking.seat_type (
	id int primary key generated always as identity,
	seat_type varchar(15) unique not null
);

create table airline_booking.plane_type (
	id int primary key generated always as identity,
	plane_name varchar(30) unique not null
);

create table airline_booking.plane_type_seat_type (
	id int primary key generated always as identity,
	plane_type_id int not null references airline_booking.plane_type(id),
	seat_type_id int not null references airline_booking.seat_type(id),
	quantity int not null
);

create table airline_booking.plane (
	id int primary key generated always as identity,
	plane_type_id int not null references airline_booking.plane_type(id)
);

create table airline_booking.airport (
	id int primary key generated always as identity,
	code varchar(3) not null,
	address varchar(200) not null
);

create table airline_booking.overbooking_rate (
	id int primary key generated always as identity,
	rate decimal(5,2) not null unique check(rate > 0)
); 

CREATE EXTENSION IF NOT EXISTS btree_gist;

create table airline_booking.scheduled_flight (
	id int primary key generated always as identity,
	departure_time timestamp not null,
	arrival_time timestamp not null check(arrival_time > departure_time),
	plane_id int not null references airline_booking.plane(id),
	departure_airport_id int not null references airline_booking.airport(id),
	arrival_airport_id int not null references airline_booking.airport(id) check(arrival_airport_id != departure_airport_id),
	overbooking_id int not null references airline_booking.overbooking_rate(id)
);

create table airline_booking.reservation (
	id int primary key generated always as identity,
	passenger_id int not null,
	scheduled_flight_id int not null,
	ticket_cost decimal(5,2) not null check(ticket_cost > 0),
	constraint fk_passenger_id foreign key (passenger_id) references airline_booking.passenger(id),
	constraint fk_scheduled_flight_id foreign key (scheduled_flight_id) references airline_booking.scheduled_flight(id)	
);

create table airline_booking.payment (
	id int primary key generated always as identity,
	reservation_id int not null, 
	amount decimal(5,2) not null,
	constraint fk_reservation_id foreign key (reservation_id) references airline_booking.reservation(id)
);

CREATE EXTENSION IF NOT EXISTS btree_gist;

create table airline_booking.flight_history (
	id int primary key generated always as identity,
	scheduled_flight_id int not null references airline_booking.scheduled_flight(id),
	plane_id int not null references airline_booking.plane(id),
	actual_departure_time timestamp,
	actual_arrival_time timestamp check(actual_arrival_time > actual_departure_time)
);

create table airline_booking.seat (
	id int primary key generated always as identity,
	reservation_id int not null,
	seat_type_id int not null,
	printed_boarding_pass_at timestamp,
	seat_number int,
	passenger_id int,
	constraint fk_ab_reservation_id foreign key (reservation_id) references airline_booking.reservation(id),
	constraint fk_ab_seat_type_id foreign key (seat_type_id) references airline_booking.seat_type(id)
);

create table airline_booking.concession_purchase (
	id int primary key generated always as identity,
	payment_id int not null,
	seat_id int not null,
	constraint cp_payment_id foreign key (payment_id) references airline_booking.payment(id),
	constraint cp_seat_id foreign key (seat_id) references airline_booking.seat(id)
);

create table airline_booking.product (
	id int primary key generated always as identity,
	concession_name varchar(200) unique not null,
	price decimal(5,2) not null check(price > 0)
);

create table airline_booking.concession_purchase_product (
	id int primary key generated always as identity,
	product_id int not null, 
	concession_purchase_id int not null,
	quantity int not null,
	constraint fk_product_id foreign key (product_id) references airline_booking.product(id),
	constraint fk_concession_purchase_id foreign key (concession_purchase_id) references airline_booking.concession_purchase(id)
);

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE airline_booking.scheduled_flight
ADD CONSTRAINT prevent_overlapping_flights
EXCLUDE USING gist
(
    plane_id WITH =,   
    tsrange(departure_time, arrival_time, '[)') WITH &&
)
WHERE (departure_time IS NOT NULL AND arrival_time IS NOT NULL);

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE airline_booking.flight_history
ADD CONSTRAINT prevent_overlapping_flights_history 
EXCLUDE USING gist 
(
	plane_id WITH =, 
	tsrange(actual_departure_time, actual_arrival_time, '[)'::text) WITH &&
) 
WHERE (((actual_departure_time IS NOT NULL) AND (actual_arrival_time IS NOT NULL)));
