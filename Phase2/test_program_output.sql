SELECT * FROM airline_booking2.flight_history;
SELECT * FROM airline_booking2.seat;
SELECT * FROM airline_booking2.concession_purchase;
SELECT * FROM airline_booking2.product;
SELECT * FROM airline_booking2.concession_purchase_product;
SELECT * FROM airline_booking2.plane_type;
SELECT * FROM airline_booking2.plane_type_seat_type;
SELECT * FROM airline_booking2.seat_type;
SELECT * FROM airline_booking2.passenger;
SELECT * FROM airline_booking2.plane;
SELECT * FROM airline_booking2.airport;
SELECT * FROM airline_booking2.scheduled_flight;
SELECT * FROM airline_booking2.overbooking_rate;
SELECT * FROM airline_booking2.reservation;
SELECT * FROM airline_booking2.payment;

SELECT 'flight_history' AS table_name, COUNT(*) AS row_count FROM airline_booking2.flight_history
UNION ALL
SELECT 'seat', COUNT(*) FROM airline_booking2.seat
UNION ALL
SELECT 'concession_purchase', COUNT(*) FROM airline_booking2.concession_purchase
UNION ALL
SELECT 'product', COUNT(*) FROM airline_booking2.product
UNION ALL
SELECT 'concession_purchase_product', COUNT(*) FROM airline_booking2.concession_purchase_product
UNION ALL
SELECT 'plane_type', COUNT(*) FROM airline_booking2.plane_type
UNION ALL
SELECT 'plane_type_seat_type', COUNT(*) FROM airline_booking2.plane_type_seat_type
UNION ALL
SELECT 'seat_type', COUNT(*) FROM airline_booking2.seat_type
UNION ALL
SELECT 'passenger', COUNT(*) FROM airline_booking2.passenger
UNION ALL
SELECT 'plane', COUNT(*) FROM airline_booking2.plane
UNION ALL
SELECT 'airport', COUNT(*) FROM airline_booking2.airport
UNION ALL
SELECT 'scheduled_flight', COUNT(*) FROM airline_booking2.scheduled_flight
UNION ALL
SELECT 'overbooking_rate', COUNT(*) FROM airline_booking2.overbooking_rate
UNION ALL
SELECT 'reservation', COUNT(*) FROM airline_booking2.reservation
UNION ALL
SELECT 'payment', COUNT(*) FROM airline_booking2.payment;

