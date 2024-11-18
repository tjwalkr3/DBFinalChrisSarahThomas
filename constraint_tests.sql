-- scheduled_flights successful insert 
-- arrival time is greater than departure time, 
-- flights do not overlap
-- departure and arrival airport are not the same
insert into airline_booking.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-06-12 03:00:00', '2024-06-12 05:00:00', 1, 2, 7),
		('2024-06-12 05:15:00', '2024-06-12 07:15:00', 1, 7, 2),
		('2024-06-12 03:30:00', '2024-06-12 09:30:00', 2, 2, 10);
		
-- flight_history successful insert 
-- arrival time is greater than departure time
-- one flight is canceled
insert into airline_booking.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (10, 1, '2024-06-12 04:00:00', '2024-06-12 06:00:00'),
		(11, 1, null, null),
		(12, 2, '2024-06-12 03:40:00', '2024-06-12 09:40:00');
		
-- product successful insert 
-- price is greater than 0
-- concession_name is unique
insert into airline_booking.product (concession_name, price)
values ('Peanuts', 1.99);

-- overbooking_reate successful insert 
-- rate is greater than 0 and unique
insert into airline_booking.overbooking_rate (rate)
values (3);

-- reservation succesful insert
-- ticket_cost is greater than 0
insert into reservation (passenger_id, scheduled_flight_id, ticket_cost)
values (1, 10, 200.00);

-- seat_type succesful insert
-- seat_type is unique
insert into seat_type (seat_type)
values ('The Throne');