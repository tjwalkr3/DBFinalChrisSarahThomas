insert into airline_booking.plane_type(plane_name) values
	('Boeing 737-200'),
	('Boeing 737-220'),
	('Boeing 747-400'),
	('Boeing 757-020'),
	('Airbus A300-03');
	
insert into airline_booking.seat_type(seat_type) values
	('coach'),
	('business class'),
	('first class');
	
insert into airline_booking.overbooking_rate(rate) values
	(2.25);
	
insert into airline_booking.airport(code, address) values
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

insert into airline_booking.plane_type_seat_type (plane_type_id, seat_type_id, quantity) values
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

insert into airline_booking.plane (plane_type_id) values
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

insert into scheduled_flight (
		departure_time, 
		arrival_time, 
		plane_id, 
		departure_airport_id, 
		arrival_airport_id, 
		overbooking_id  
	)  values
	-- Flights scheduled on 08/16/2024  
	-- Plane 1, Boeing 737-200 (only coach seats available)  
	('2024-08-16 04:30:00', '2024-08-16 06:35:00', 1, 7, 2, 1), -- 2hr 5min from SLC to LAX  
	('2024-08-16 06:50:00', '2024-08-16 13:00:00', 1, 2, 1, 1), -- 5hr 25min from LAX to JFK  
	('2024-08-16 13:15:00', '2024-08-16 19:30:00', 1, 1, 3, 1), -- 6hr 15min from JFJ ti SEA  
	-- Plane 2, Boeing 737-200 (only coach seats available)  
	('2024-08-16 00:05:00', '2024-08-16 07:15:00', 2, 10, 9, 1), -- 7hr 10min from ANC to AGS  
	('2024-08-16 04:30:00', '2024-08-16 06:30:00', 2, 9, 5, 1), -- 1hr 45min from AGS to MDW  
	('2024-08-16 06:45:00', '2024-08-16 08:45:00', 2, 5, 6, 1); -- 4hr from MDW to SFO
	
insert into flight_history
(scheduled_flight_id, plane_id, actual_departure_time, actual_arrival_time)
values (1, 1, '2024-08-16 04:40:00', '2024-08-16 06:45:00'),
		(2, 1, '2024-08-16 07:20:00', '2024-08-16 13:20:00'),
		(4, 2,'2024-08-16 00:15:00', '2024-08-16 07:30:00'),
		(5, 2, '2024-08-16 05:30:00', '2024-08-16 07:30:00'),
		(6, 2, default, default);
	
insert into airline_booking.passenger
(passenger_name, passport_id, phone, email, address)
values ('Thomas Jones', '123456789', '801-420-6666', 'thomas@gmail.com', '123 W 456 S, Seattle, WA'),
		('Sarah Martin', '987654321', '123-456-7890', 'sarah@gmail.com', '321 W 654 S, Salt Lake City, UT'),
		('Chris Young', '123789456', '666-420-6969', 'chris@gmail.com',  '222 W 222 S, Denver, CO'),
		('Taft Allen', '111222333', '420-666-6969', 'taft@gmail.com',  '111 W 111 S, Los Angelos, CA'),
		('Ricardo Ruiz', '333222111', '420-111-2222', 'ricardo@gmail.com', '420 Ave 666, Sanfransico, CA'),
		('Cody Howell', '444555666', '801-420-7777', 'cody@gmail.com',  '121 W 323 S, Chicago, IL'),
		('Nathan Howell', '777888999', '801-420-8888', 'nathan@gmail.com', '333 W 444 S, Layton, UT');
	
insert into airline_booking.reservation 
(passenger_id, scheduled_flight_id, ticket_cost)
values (1, 1, 200.00),
		(2, 1, 200.00),
		(3, 2, 150.00),
		(6, 5, 200.00),
		(5, 5, 150.00),
		(7, 6, 200.00);
	
insert into airline_booking.seat
(reservation_id, seat_type_id, printed_boarding_pass_at, seat_number, passenger_id)
values (1, 1, '2024-08-16 02:30:00',1, 1),
		(1, 1, '2024-08-16 02:31:00',2, 4)
		(2, 1, '2024-08-16 04:53:00',3, 2),
		(3, 1, '2024-08-16 05:31:00',20, 3),
		(4, 1, '2024-08-16 02:00:00',30, 6),
		(5, 1, default, DEFAULT, default),
		(6, 1, '2024-08-16 04:30:00', 31, 7);
	
INSERT INTO airline_booking.payment
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
		(6, -200.00);
	
insert into airline_booking.product (concession_name, price) values
	('Pillow', 8.16),
	('Blanket', 6.12),
	('Headphones', 20.99),
	('Candy bar', 3.99),
	('Fountain drink', 2.89),
	('Chewing gum', 1.99);
		
INSERT INTO airline_booking.concession_purchase
(payment_id, seat_id)
VALUES (2, 1),
		(3, 2),
		(5, 3);

INSERT INTO airline_booking.concession_purchase_product
(product_id, concession_purchase_id, quantity)
VALUES (4, 1, 1),
		(5, 2, 2),
		(6, 3, 1);
