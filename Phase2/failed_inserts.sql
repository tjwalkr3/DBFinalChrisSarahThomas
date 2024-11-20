-- scheduled flights insert fail
-- arrival time less than departure time
insert into airline_booking.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-06-11 03:00:00', '2024-06-11 02:00:00', 1, 2, 3, 1);

-- scheduled flights insert fail
-- arrival and departure airports are the same
insert into airline_booking.scheduled_flight (departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
values ('2024-06-11 06:00:00', '2024-06-11 08:00:00', 1, 2, 2, 1);

-- flight_history insert fail 
-- arrival time is less than departure time
insert into airline_booking.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (7, 1, '2024-08-21 010:00:00', '2024-08-21 08:00:00');

--flight_history insert fail
--flights overlap
insert into airline_booking.flight_history (scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (7, 2, '2024-08-16 10:10:00.000', '2024-08-16 12:10:00');

-- product insert fail
-- concession_name is not unique
insert into airline_booking.product (concession_name, price)
values ('Chewing gum', 2.99);

-- product insert fail
--price is less than 0
insert into airline_booking.product (concession_name, price)
values ('Pistachios', -1.99);

-- overbooking_reate insert fail 
-- rate is less than 0
insert into airline_booking.overbooking_rate (rate)
values (-1);

-- overbooking_reate insert fail
-- rate is not unique
insert into airline_booking.overbooking_rate (rate)
values (2.25);

-- reservation insert fail
-- ticket_cost is less than 0
insert into airline_booking.reservation (passenger_id, scheduled_flight_id, ticket_cost)
values (1, 9, -100.00);

-- seat_type insert fail
-- seat_type is not unique
insert into airline_booking.seat_type (seat_type)
values ('coach');
