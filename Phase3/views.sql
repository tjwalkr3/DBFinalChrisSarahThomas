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