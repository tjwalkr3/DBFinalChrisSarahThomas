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

-- schedule_flight procedure
-- unimplemented
create or replace procedure schedule_flight
(departure_time timestamp, arrival_time timestamp, plane_id int, departure_airport_id int, arrival_airport_id int, overbooking_id int) 
as $$
	declare
		flightId int;
	begin
		insert into airline_booking2.scheduled_flight 
		(departure_time, arrival_time, plane_id, departure_airport_id, arrival_airport_id, overbooking_id)
		values departure_time, arrival_time, plane_id, departure_airport_id, overbooking_id;
		call --procedure to check flight chains
	exception
		when invalid_flight then
			raise notice 'plane not available in those locations'
			delete from airline_booking2.scheduled_flight where id = flightId;
	end;
$$ language plpgsql;

-- flight continuity procedure
-- makes sure planes aren't teleporting between flights
CREATE OR REPLACE PROCEDURE flight_continuity ()
LANGUAGE plpgsql
AS $$
DECLARE
    current_row RECORD;
    -- Variable to hold each row during iteration
    last_row RECORD;
    -- Variable to store the last row
BEGIN
    FOR current_row IN
    SELECT
        id,
        departure_airport_id,
        arrival_airport_id,
        plane_id
    FROM
        airline_booking2.scheduled_flight
    ORDER BY
        plane_id ASC,
        departure_time ASC -- Ensure rows are processed in a defined order
        LOOP
            -- If last_row is not null, perform the comparison
            IF last_row IS NOT NULL THEN
                IF last_row.arrival_airport_id = current_row.departure_airport_id THEN
                    --RAISE NOTICE 'Row continuity check passed: Plane ID=%, Last Arrival=%, Current Departure=%', last_row.plane_id, last_row.arrival_airport_id, current_row.departure_airport_id;
                ELSIF last_row.plane_id != current_row.plane_id THEN
                    --RAISE NOTICE 'Row continuity check passed: new plane: Plane ID=%, Departure=%', last_row.plane_id, current_row.departure_airport_id;
                ELSE
                    RAISE WARNING 'Row continuity check failed: Flight ID=%, Last Arrival=%, Current Departure=%', current_row.id, last_row.arrival_airport_id, current_row.departure_airport_id;
                END IF;
            END IF;
            -- Update last_row to hold the current_row for the next iteration
            last_row := current_row;
        END LOOP;
END;
$$;

CALL flight_continuity();
