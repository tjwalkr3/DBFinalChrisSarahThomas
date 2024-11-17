INSERT INTO airline_booking.plane_type (plane_name) values 
	('Boeing 737-200'),
    ('Boeing 737-220'),
    ('Boeing 747-400'),
    ('Boeing 757-020'),
    ('Airbus A300-03');
	
INSERT INTO airline_booking.seat_type (seat_type) VALUES
    ('coach'),
    ('business class'),
    ('first class');
	
INSERT INTO airline_booking.overbooking_rate (rate) VALUES
    (2.25);
	
INSERT INTO airline_booking.airport (code, address) VALUES
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

INSERT INTO airline_booking.plane_type_seat_type (plane_type_id, seat_type_id, quantity) VALUES
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

INSERT INTO airline_booking.plane (plane_type_id) VALUES
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

INSERT INTO airline_booking.scheduled_flight (departure_time,arrival_time,plane_id,departure_airport_id,arrival_airport_id,overbooking_id) VALUES
	 ('2024-08-16 04:30:00','2024-08-16 06:35:00',1,7,2,1),
	 ('2024-08-16 06:50:00','2024-08-16 13:00:00',1,2,1,1),
	 ('2024-08-16 13:15:00','2024-08-16 19:30:00',1,1,3,1),
	 ('2024-08-21 07:00:00','2024-08-21 09:00:00',1,2,3,1),
	 ('2024-08-22 04:30:00','2024-08-22 06:30:00',2,3,5,1),
	 ('2024-08-16 07:30:00','2024-08-16 09:30:00',2,10,9,1),
	 ('2024-08-16 09:45:00','2024-08-16 12:00:00',2,9,5,1),
	 ('2024-08-16 12:15:00','2024-08-16 14:15:00',2,5,6,1),
	 ('2024-08-21 09:45:00','2024-08-21 11:45:00',1,3,2,1);

INSERT INTO airline_booking.flight_history (scheduled_flight_id,plane_id,actual_departure_time,actual_arrival_time) VALUES
	 (1,1,'2024-08-16 04:40:00','2024-08-16 06:45:00'),
	 (2,1,'2024-08-16 07:20:00','2024-08-16 13:20:00'),
	 (4,2,'2024-08-16 00:15:00','2024-08-16 07:30:00'),
	 (5,2,'2024-08-16 05:30:00','2024-08-16 07:30:00'),
	 (6,2,NULL,NULL);
   
INSERT INTO airline_booking.passenger (passenger_name, passport_id, phone, email, address) VALUES 
    ('Thomas Jones', '123456789', '801-420-6666', 'thomas@gmail.com', '123 W 456 S, Seattle, WA'),
    ('Sarah Martin', '987654321', '123-456-7890', 'sarah@gmail.com', '321 W 654 S, Salt Lake City, UT'),
    ('Chris Young', '123789456', '666-420-6969', 'chris@gmail.com', '222 W 222 S, Denver, CO'),
    ('Taft Allen', '111222333', '420-666-6969', 'taft@gmail.com', '111 W 111 S, Los Angeles, CA'),
    ('Ricardo Ruiz', '333222111', '420-111-2222', 'ricardo@gmail.com', '420 Ave 666, San Francisco, CA'),
    ('Cody Howell', '444555666', '801-420-7777', 'cody@gmail.com', '121 W 323 S, Chicago, IL'),
    ('Nathan Howell', '777888999', '801-420-8888', 'nathan@gmail.com', '333 W 444 S, Layton, UT');
		
insert into airline_booking.reservation 
(passenger_id, scheduled_flight_id, ticket_cost)
values (1, 1, 200.00),
		(2, 1, 200.00),
		(3, 2, 150.00),
		(6, 5, 200.00),
		(5, 5, 150.00),
		(7, 6, 200.00),
		(1, 7, 200.00),
		(2, 7, 200.00),
		(5, 8, 150.00),
		(7, 9, 200.00),
		(6, 9, 200.00);

INSERT INTO airline_booking.seat (reservation_id, seat_type_id, printed_boarding_pass_at, seat_number, passenger_id) VALUES 
    (1, 1, '2024-08-16 02:30:00', 1, 1),
    (1, 1, '2024-08-16 02:31:00', 2, 4),
    (2, 1, '2024-08-16 04:53:00', 3, 2),
    (3, 1, '2024-08-16 05:31:00', 20, 3),
    (4, 1, '2024-08-16 02:00:00', 30, 6),
    (5, 1, DEFAULT, DEFAULT, DEFAULT),
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
		(6, -200.00),
		(7, 200.00),
		(8, 200.00),
		(9, 150.00),
		(10, 200.00),
		(11, 200.00);
		
insert into airline_booking.product (concession_name, price) values
	('Pillow', 8.16),
	('Blanket', 6.12),
	('Headphones', 20.99),
	('Candy bar', 3.99),
	('Fountain drink', 2.89),
	('Chewing gum', 1.99);

INSERT INTO airline_booking.product (concession_name, price) VALUES
    ('Pillow', 8.16),
    ('Blanket', 6.12),
    ('Headphones', 20.99),
    ('Candy bar', 3.99),
    ('Fountain drink', 2.89),
    ('Chewing gum', 1.99);
		
INSERT INTO airline_booking.concession_purchase (payment_id, seat_id) VALUES 
    (2, 1),
    (3, 2),
    (5, 3);

INSERT INTO airline_booking.concession_purchase_product (product_id, concession_purchase_id, quantity) VALUES 
    (4, 1, 1),
    (5, 2, 2),
    (6, 3, 1);
