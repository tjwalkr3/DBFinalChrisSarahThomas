-- Concessions Test 1: Show total number of each item for each seat
select cp.seat_id,
	p.concession_name, 
	p.price,
	cpp.quantity
from product p
inner join concession_purchase_product cpp 
on (p.id = cpp.product_id)
inner join concession_purchase cp 
on (cpp.concession_purchase_id = cp.id)
inner join payment p2 
on (cp.payment_id = p2.id)
group by (p.concession_name, p.price, cpp.quantity, cp.seat_id)
order by cp.seat_id asc;

-- Concessions Test 2: Get total concession cost for each seat
select cp.seat_id, sum(p.amount) as total_concession_cost
from concession_purchase cp
inner join seat s
on (cp.seat_id = s.id) 
inner join payment p
on (cp.payment_id = p.id)
group by cp.seat_id 
order by cp.seat_id asc;

-- Seats Filled Test
SELECT
	r.id,
	p.passenger_name,
	count(*)
FROM
passenger p
INNER JOIN reservation r 
ON (p.id = r.passenger_id)
INNER JOIN seat s
ON (r.id = s.reservation_id)
WHERE s.printed_boarding_pass_at IS NOT NULL
GROUP BY r.id, p.passenger_name;

-- Reservations Test 1: Get each reservation and the time each flight leaves
select p.id as passenger_id, 
	p.passenger_name, 
	r.ticket_cost, 
	sf.id as flight_id,
	sf.departure_time, 
	sf.arrival_time 
from reservation r
inner join passenger p 
on (r.passenger_id = p.id) 
inner join scheduled_flight sf 
on (r.scheduled_flight_id = sf.id)
order by p.id asc;

-- Reservations Test 2: reservations may be overbooked (up to the maximum overbooking target number)
with total_seats as (
	select pt.plane_name,
		ptst.plane_type_id,
		sum(ptst.quantity) as num_seats 
	from plane_type_seat_type ptst
	inner join seat_type st
	on (ptst.seat_type_id = st.id)
	inner join plane_type pt
	on (ptst.plane_type_id = pt.id)
	group by pt.plane_name, ptst.plane_type_id
), seats_booked as (
	select p.plane_type_id,
		sf.id as flight_id,
		count(*) as num_booked
	from seat s
	inner join reservation r
	on (s.reservation_id = r.id)
	inner join scheduled_flight sf 
	on (r.scheduled_flight_id = sf.id)
	inner join plane p 
	on (sf.plane_id = p.id)
	where s.printed_boarding_pass_at is not null
	group by p.plane_type_id, sf.id
)
select sb.flight_id,
	CASE
	  WHEN (sb.num_booked / ts.num_seats) < 1 THEN 0
	ELSE
	  (1 - (sb.num_booked / ts.num_seats)) * 100
	end as percent_overbooked
from total_seats ts
inner join seats_booked sb
on (ts.plane_type_id = sb.plane_type_id);
