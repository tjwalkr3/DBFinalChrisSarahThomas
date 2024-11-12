drop schema if exists airline_booking cascade;
create schema airline_booking;

create table SeatType (
	id int primary key generated always as identity,
	seat_type varchar(15) not null
);

create table PlaneType (
	id int primary key generated always as identity,
	plane_name varchar(30) not null
);

create table PlaneType_SeatType (
	id int primary key generated always as identity,
	plane_type_id int not null references PlaneType(id),
	seat_type_id int not null references SeatType(id),
	quantity int not null
);

create table Plane (
	id int primary key generated always as identity,
	plane_type_id int not null references PlaneType(id)
);

create table Airport (
	id int primary key generated always as identity,
	code varchar(3) not null,
	address varchar(200) not null
);

create table OverbookingRate (
	id int primary key generated always as identity,
	rate decimal(2,2) not null
); 

create table ScheduledFlight (
	id int primary key generated always as identity,
	departure_time timestamp not null,
	arrival_time timestamp not null,
	plane_id int not null references Plane(id),
	departure_airport_id int not null references Airport(id),
	arrival_airport_id int not null references Airport(id),
	overbooking_id int not null references OverbookingRate(id)
);

create table FlightHistory (
	id int primary key generated always as identity,
	scheduled_flight_id int not null references ScheduledFlight(id),
	plane_id int not null references Plane(id),
	actual_departure_time timestamp,
	actual_arrival_time timestamp,
	delay_interval interval
);