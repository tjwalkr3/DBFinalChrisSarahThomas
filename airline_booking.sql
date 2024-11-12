drop schema if exists airline_booking cascade;
create schema airline_booking;

create table passenger (
	id int primary key generated always as identity,
	passenger_name varchar(100) not null, 
	passport_id varchar(9),
	phone varchar(15) not null,
	email varchar(200), 
	address varchar(200) not null
);

create table seat_type (
	id int primary key generated always as identity,
	seat_type varchar(15) not null
);

create table plane_type (
	id int primary key generated always as identity,
	plane_name varchar(30) not null
);

create table plane_type_seat_type (
	id int primary key generated always as identity,
	plane_type_id int not null references plane_type(id),
	seat_type_id int not null references seat_type(id),
	quantity int not null
);

create table plane (
	id int primary key generated always as identity,
	plane_type_id int not null references plane_type(id)
);

create table airport (
	id int primary key generated always as identity,
	code varchar(3) not null,
	address varchar(200) not null
);

create table overbooking_rate (
	id int primary key generated always as identity,
	rate decimal(2,2) not null
); 

create table scheduled_flight (
	id int primary key generated always as identity,
	departure_time timestamp not null,
	arrival_time timestamp not null,
	plane_id int not null references plane(id),
	departure_airport_id int not null references airport(id),
	arrival_airport_id int not null references airport(id),
	overbooking_id int not null references overbooking_rate(id)
);

create table reservation (
	id int primary key generated always as identity,
	seat_type_id int not null, 
	passenger_id int not null,
	scheduled_flight_id int not null,
	printed_boarding_pass_at timestamp,
	ticket_cost decimal(5,2) not null,
	seat_number int,
	constraint fk_seat_type_id foreign key (seat_type_id) references seat_type(id),
	constraint fk_passenger_id foreign key (passenger_id) references passenger(id),
	constraint fk_scheduled_flight_id foreign key (scheduled_flight_id) references scheduled_flight(id)	
)

create table payment (
	id int primary key generated always as identity,
	reservation_id int not null, 
	amount decimal(5,2) not null,
	compensation boolean not null,
	constraint fk_reservation_id foreign key (reservation_id) references reservation(id)
)

create table flight_history (
	id int primary key generated always as identity,
	scheduled_flight_id int not null references scheduled_flight(id),
	plane_id int not null references plane(id),
	actual_departure_time timestamp,
	actual_arrival_time timestamp,
	delay_interval interval
);