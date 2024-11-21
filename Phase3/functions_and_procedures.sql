-- flight performance function
-- calculates percentages based on the flights that have been canceled
create or replace function flight_performance_efficiency() returns table(percent_flights_on_time int, percent_flights_canceled int) as $$
	begin
	return query with flight_counts as (
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
	from airline_booking2.flight_history fh
	)
	select 
		(coalesce(on_time_flights, 0) * 100.0 / coalesce(total_flights, 1))::int as percent_flights_on_time,
		(coalesce(canceled_flights, 0) * 100.0 / coalesce(total_flights, 1))::int as percent_flights_canceled
	from flight_counts;
	end;
$$ language plpgsql;

select * from flight_performance_efficiency();