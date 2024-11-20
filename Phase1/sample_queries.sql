-- Concessions Test 1: Show total number of each item for each seat
select cp.seat_id,
	p.concession_name, 
	p.price,
	cpp.quantity
from airline_booking.product p
inner join airline_booking.concession_purchase_product cpp 
on (p.id = cpp.product_id)
inner join airline_booking.concession_purchase cp 
on (cpp.concession_purchase_id = cp.id)
inner join airline_booking.payment p2 
on (cp.payment_id = p2.id)
group by (p.concession_name, p.price, cpp.quantity, cp.seat_id)
order by cp.seat_id asc;

-- Concessions Test 2: Get total concession cost for each seat
select cp.seat_id, sum(p.amount) as total_concession_cost
from airline_booking.concession_purchase cp
inner join airline_booking.seat s
on (cp.seat_id = s.id) 
inner join airline_booking.payment p
on (cp.payment_id = p.id)
group by cp.seat_id 
order by cp.seat_id asc;

-- Reservations Test 1: reservation is for a flight on a certain date/time
select p.id as passenger_id, 
	p.passenger_name, 
	r.ticket_cost, 
	sf.id as flight_id,
	sf.departure_time, 
	sf.arrival_time 
from airline_booking.reservation r
inner join airline_booking.passenger p 
on (r.passenger_id = p.id) 
inner join airline_booking.scheduled_flight sf 
on (r.scheduled_flight_id = sf.id)
order by p.id asc;

-- Reservations Test 2: reservations may be overbooked (up to the maximum overbooking target number)
with total_seats as (
	select pt.plane_name,
		ptst.plane_type_id,
		sum(ptst.quantity) as num_seats 
	from airline_booking.plane_type_seat_type ptst
	inner join airline_booking.seat_type st
	on (ptst.seat_type_id = st.id)
	inner join airline_booking.plane_type pt
	on (ptst.plane_type_id = pt.id)
	group by pt.plane_name, ptst.plane_type_id
), seats_booked as (
	select p.plane_type_id,
		sf.id as flight_id,
		count(*) as num_booked
	from airline_booking.seat s
	inner join airline_booking.reservation r
	on (s.reservation_id = r.id)
	inner join airline_booking.scheduled_flight sf 
	on (r.scheduled_flight_id = sf.id)
	inner join airline_booking.plane p 
	on (sf.plane_id = p.id)
	where s.printed_boarding_pass_at is not null
	group by p.plane_type_id, sf.id
)
select sf.id as flight_id,
	(cast(coalesce(sb.num_booked, 0) as float) / cast(ts.num_seats as float)) * 100 as percent_booked
from airline_booking.scheduled_flight sf
inner join airline_booking.plane p
on (sf.plane_id = p.id)
inner join total_seats ts
on (ts.plane_type_id = p.plane_type_id)
left join seats_booked sb
on (sf.id = sb.flight_id)
order by flight_id asc;

-- Passengers who print a boarding pass are guaranteed a seat.
with with_boarding_pass as (
    select
        r.id as reservation_id,
        p.passenger_name,
        count(*) as num_assigned_seats,
        true as has_boarding_pass
    from airline_booking.passenger p
    inner join airline_booking.reservation r 
        on p.id = r.passenger_id
    inner join airline_booking.seat s
        on r.id = s.reservation_id
    where s.printed_boarding_pass_at is not null
    group by r.id, p.passenger_name
), without_boarding_pass as (
    select
        r.id as reservation_id,
        p.passenger_name,
        0 as num_assigned_seats,
        false as printed_boarding_pass
    from airline_booking.passenger p
    inner join airline_booking.reservation r 
        on p.id = r.passenger_id
    inner join airline_booking.seat s
        on r.id = s.reservation_id
    where s.printed_boarding_pass_at is null
      and s.seat_number is null
)
select * from with_boarding_pass
union all
select * from without_boarding_pass
order by reservation_id asc;

-- Flight Revenue efficiency (% seats sold, % overbooking reservations paid out )
with total_seats as (
	select pt.plane_name,
		ptst.plane_type_id,
		sum(ptst.quantity) as num_seats 
	from airline_booking.plane_type_seat_type ptst
	inner join airline_booking.seat_type st
	on (ptst.seat_type_id = st.id)
	inner join airline_booking.plane_type pt
	on (ptst.plane_type_id = pt.id)
	group by pt.plane_name, ptst.plane_type_id
), seats_booked as (
	select p.plane_type_id,
		sf.id as flight_id,
		count(*) as num_booked
	from airline_booking.seat s
	inner join airline_booking.reservation r
	on (s.reservation_id = r.id)
	inner join airline_booking.scheduled_flight sf 
	on (r.scheduled_flight_id = sf.id)
	inner join airline_booking.plane p 
	on (sf.plane_id = p.id)
	where s.printed_boarding_pass_at is not null
	group by p.plane_type_id, sf.id
), overbooked_paid as (
	select sf.id as flight_id,
		count(*) as overbooked_paid_out
	from airline_booking.reservation r
	inner join airline_booking.scheduled_flight sf 
	on (r.scheduled_flight_id = sf.id)
	inner join airline_booking.payment pay
	on (r.id = pay.reservation_id and pay.amount < 0) -- Negative payment indicates compensation
	group by sf.id
)
select sf.id as flight_id,
	-- Calculate % Seats Sold
	coalesce(
		(cast(coalesce(sb.num_booked, 0) as float) / cast(ts.num_seats as float)) * 100, 0
	) as percent_seats_sold,
	-- Calculate % Overbooking Reservations Paid Out
	coalesce(
		(cast(coalesce(op.overbooked_paid_out, 0) as float) / cast(sb.num_booked as float)) * 100, 0
	) as percent_passengers_refunded
from airline_booking.scheduled_flight sf
inner join airline_booking.plane p
on (sf.plane_id = p.id)
inner join total_seats ts
on (ts.plane_type_id = p.plane_type_id)
left join seats_booked sb
on (sf.id = sb.flight_id)
left join overbooked_paid op
on (sf.id = op.flight_id)
order by flight_id asc;

-- Flight Estimations Query/Function
create or replace function flight_estimate(startdate date) 
returns table(start_date date, end_date date, revenue decimal(5,2)) as $$
begin
    return query 
    select
        (select min(departure_time)::date 
         from airline_booking.scheduled_flight 
         where departure_time >= flight_estimate.startdate) as start_date,

        (startdate + interval '10 days')::date as end_date,

        sum(p.amount)::decimal(5,2) as revenue
    from airline_booking.scheduled_flight sf
    inner join airline_booking.reservation r
        on sf.id = r.scheduled_flight_id
    inner join airline_booking.payment p
        on r.id = p.reservation_id
    where sf.departure_time >= flight_estimate.startdate
      and sf.arrival_time < (startdate + interval '10 days')
    group by start_date, end_date; -- Group by to return correct aggregates
end;
$$ language plpgsql;


select * from flight_estimate('08-21-24');

-- Flight performance efficiency (% flights on time, % flights canceled)
with flight_counts as (
	select 
		count(*) as total_flights,
		sum(case 
				when fh.actual_departure_time is null and fh.actual_arrival_time is null then 1 
				else 0 
			end
		) as canceled_flights,
		sum(case 
				when fh.actual_departure_time is not null and fh.actual_arrival_time is not null then 1  
				else 0 
			end
		) as on_time_flights
	from airline_booking.flight_history fh
)
select 
	(coalesce(on_time_flights, 0) * 100.0 / coalesce(total_flights, 1)) as percent_flights_on_time,
	(coalesce(canceled_flights, 0) * 100.0 / coalesce(total_flights, 1)) as percent_flights_canceled
from flight_counts;

