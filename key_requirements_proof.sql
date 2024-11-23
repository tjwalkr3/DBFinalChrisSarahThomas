-- gets the passenger count and plane capacity for each flight
with plane_capacities as (
	select p.id as plane_id, sum(ptst.quantity) as plane_capacity
	from plane p
	inner join plane_type pt 
	on (p.plane_type_id = pt.id)
	inner join plane_type_seat_type ptst 
	on (ptst.plane_type_id = pt.id)
	group by p.id
),
passenger_counts as (
	select sf.id as scheduled_flight_id, sf.plane_id, count(*) as reservation_count
	from scheduled_flight sf 
	inner join reservation r
	on (sf.id = r.scheduled_flight_id)
	group by sf.id, sf.plane_id
)
select pcts.scheduled_flight_id, 
	pc.plane_capacity, 
	pcts.reservation_count, 
	(pcts.reservation_count / pc.plane_capacity::decimal * 100) as percent_booked
from plane_capacities pc
inner join passenger_counts pcts
on (pc.plane_id = pcts.plane_id)
order by pcts.scheduled_flight_id asc;
