insert into plane_type(plane_name) values
	('Boeing 737-200'),
	('Boeing 737-220'),
	('Boeing 747-400'),
	('Boeing 757-020'),
	('Airbus A300-03');
	
insert into seat_type(seat_type) values
	('coach'),
	('business class'),
	('first class');
	
insert into overbooking_rate(rate) values
	(2.25);
	
insert into airport(code, address) values
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

insert into product (concession_name, price) values
	('Pillow', 8.16),
	('Blanket', 6.12),
	('Headphones', 20.99),
	('Candy bar', 3.99),
	('Fountain drink', 2.89),
	('Chewing gum', 1.99);

insert into plane_type_seat_type (plane_type_id, seat_type_id, quantity) values
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

insert into plane (plane_type_id) values
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