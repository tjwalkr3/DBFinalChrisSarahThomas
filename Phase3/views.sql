create view plane_total_flight_time as
	select
		p.id plane_id,
		sum(age(fh.actual_arrival_time, fh.actual_departure_time)) total_hours_flight_time
	from
	flight_history fh
	inner join plane p on (p.id = fh.plane_id)
	where (fh.actual_departure_time is not null and fh.actual_arrival_time is not null)
	group by p.id
	order by p.id;

create view customer_flight_expenses as
	select 
		p.id passenger_id,
		p.passenger_name,
		sf.departure_time::date flight_departure_date,
		sf.plane_id,
		ad.code departure_airport_code,
		aa.code arrival_airport_code,
		sum(pay.amount) amount_spent
	from 
	payment pay
	inner join reservation r on (pay.reservation_id = r.id)
	inner join scheduled_flight sf on (sf.id = r.scheduled_flight_id)
	inner join passenger p on (p.id = r.passenger_id)
	inner join airport ad on (ad.id = sf.departure_airport_id)
	inner join airport aa on (aa.id = sf.arrival_airport_id)
	group by p.id, p.passenger_name, sf.plane_id, flight_departure_date, departure_airport_code, arrival_airport_code
	order by passenger_name asc;