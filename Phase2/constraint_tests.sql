begin transaction;
	-- scheduled_flights successful insert 
	-- arrival time is greater than departure time, 
	-- flights do not overlap
	-- departure and arrival airport are not the same
	insert into airline_booking2.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
	values ('2024-06-12 03:00:00', '2024-06-12 05:00:00', 1, 2, 7, 1),
			('2024-06-12 05:15:00', '2024-06-12 07:15:00', 1, 7, 2, 1),
			('2024-06-12 03:30:00', '2024-06-12 09:30:00', 2, 2, 10, 1);
	
	select * from airline_booking2.scheduled_flight;

	-- scheduled_flights insert fail
	--overlapping flight
	insert into airline_booking2.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
	values ('2024-06-12 03:00:00', '2024-06-12 05:00:00', 1, 2, 3, 1);
rollback;

-- scheduled_flights insert fail
--overlapping flight
insert into airline_booking2.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-08-22 03:00:00', '2024-08-22 05:00:00', 2, 2, 3, 1);

SELECT setval(pg_get_serial_sequence('airline_booking2.scheduled_flight', 'id'), coalesce(MAX(id), 1))
from airline_booking2.scheduled_flight;

-- scheduled flights insert fail
-- arrival time less than departure time
insert into airline_booking2.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-06-11 03:00:00', '2024-06-11 02:00:00', 1, 2, 3, 1);

-- scheduled flights insert fail
-- arrival and departure airports are the same
insert into airline_booking2.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-06-11 06:00:00', '2024-06-11 08:00:00', 1, 2, 2, 1);

select * from airline_booking2.scheduled_flight;

begin transaction;
	-- flight_history successful insert 
	-- arrival time is greater than departure time
	-- one flight is canceled
	insert into airline_booking2.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
	values (7, 1, '2024-08-21 010:00:00', '2024-08-21 12:00:00'),
			(8, 1, null, null),
			(9, 2, '2024-08-22 04:40:00', '2024-08-22 06:40:00');

	select * from airline_booking2.flight_history;
rollback;

SELECT setval(pg_get_serial_sequence('airline_booking2.flight_history', 'id'), coalesce(MAX(id), 1))
from airline_booking2.flight_history;

-- flight_history insert fail 
-- arrival time is less than departure time
insert into airline_booking2.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (7, 1, '2024-08-21 010:00:00', '2024-08-21 08:00:00');

--flight_history insert fail
--flights overlap
insert into airline_booking2.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (7, 2, '2024-08-16 10:10:00.000', '2024-08-16 12:10:00');


begin transaction;
	-- product successful insert 
	-- price is greater than 0
	-- concession_name is unique
	insert into airline_booking2.product (concession_name, price)
	values ('Peanuts', 1.99);

	select * from airline_booking2.product;

rollback;

SELECT setval(pg_get_serial_sequence('airline_booking2.product', 'id'), coalesce(MAX(id), 1))
from airline_booking2.product;

-- product insert fail
-- concession_name is not unique
insert into airline_booking2.product (concession_name, price)
values ('Chewing gum', 2.99);

-- product insert fail
--price is less than 0
insert into airline_booking2.product (concession_name, price)
values ('Pistachios', -1.99);

begin transaction;
	-- overbooking_reate successful insert 
	-- rate is greater than 0 and unique
	insert into airline_booking2.overbooking_rate (rate)
	values (3);

	select * from airline_booking2.overbooking_rate;
rollback;

SELECT setval(pg_get_serial_sequence('airline_booking2.overbooking_rate', 'id'), coalesce(MAX(id), 1))
from airline_booking2.overbooking_rate;

-- overbooking_reate insert fail 
-- rate is less than 0
insert into airline_booking2.overbooking_rate (rate)
values (-1);

-- overbooking_reate insert fail
-- rate is not unique
insert into airline_booking2.overbooking_rate (rate)
values (2.25);

begin transaction;
	-- reservation succesful insert
	-- ticket_cost is greater than 0
	insert into airline_booking2.reservation (passenger_id, scheduled_flight_id, ticket_cost)
	values (1, 9, 200.00);

	select * from airline_booking2.reservation;
rollback;

SELECT setval(pg_get_serial_sequence('airline_booking2.reservation', 'id'), coalesce(MAX(id), 1))
from airline_booking2.reservation;

-- reservation insert fail
-- ticket_cost is less than 0
insert into airline_booking2.reservation (passenger_id, scheduled_flight_id, ticket_cost)
values (1, 9, -100.00);

begin transaction;
	-- seat_type succesful insert
	-- seat_type is unique
	insert into airline_booking2.seat_type (seat_type)
	values ('The Throne');

	select * from airline_booking2.seat_type;
rollback;

SELECT setval(pg_get_serial_sequence('airline_booking2.seat_type', 'id'), coalesce(MAX(id), 1))
from airline_booking2.seat_type;

-- seat_type insert fail
-- seat_type is not unique
insert into airline_booking2.seat_type (seat_type)
values ('coach');
