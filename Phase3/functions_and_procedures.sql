-- flight performance efficiency function
-- calculates percentages based on the flights that have been canceled
create or replace function flight_performance_efficiency() returns table(percent_flights_on_time decimal(10,6), percent_flights_canceled decimal(10,6)) as $$
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
		(coalesce(on_time_flights, 0) * 100.0 / coalesce(total_flights, 1))::decimal(10,6) as percent_flights_on_time,
		(coalesce(canceled_flights, 0) * 100.0 / coalesce(total_flights, 1))::decimal(10,6) as percent_flights_canceled
	from flight_counts;
	end;
$$ language plpgsql;

select * from flight_performance_efficiency();

-- Flight Estimations Query/Function
-- Calculates the expected revenue within a 10 day interval after a given startdate
create or replace function flight_revenue_estimate(startdate date) 
returns table(start_date date, end_date date, revenue decimal(10,2)) as $$
begin
    return query 
    select
        (select min(departure_time)::date 
         from airline_booking2.scheduled_flight 
         where departure_time >= flight_revenue_estimate.startdate) as start_date,

        (startdate + interval '10 days')::date as end_date,

        sum(p.amount)::decimal(10,2) as revenue
    from airline_booking2.scheduled_flight sf
    inner join airline_booking2.reservation r
        on sf.id = r.scheduled_flight_id
    inner join airline_booking2.payment p
        on r.id = p.reservation_id
    where sf.departure_time >= flight_revenue_estimate.startdate
      and sf.arrival_time < (startdate + interval '10 days')
    group by start_date, end_date; -- Group by to return correct aggregates
end;
$$ language plpgsql;


select * from flight_estimate('08-21-24');

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

-- scheduled_flight insert procedure
-- make sure that the departure airport of the flight being inserted is the same as the arrival airport of the last flight
CREATE OR REPLACE PROCEDURE insert_scheduled_flight(new_flight RECORD)
LANGUAGE plpgsql AS $$
DECLARE
    last_flight RECORD; -- To hold the most recent flight for the plane
BEGIN
    -- Fetch the most recent flight for the given plane
    SELECT *
    INTO last_flight
    FROM airline_booking2.scheduled_flight
    WHERE plane_id = new_flight.plane_id
    ORDER BY departure_time DESC
    LIMIT 1;

    -- Perform the continuity check if a previous flight exists
    IF last_flight IS NOT NULL THEN
        IF last_flight.arrival_airport_id != new_flight.departure_airport_id THEN
            RAISE EXCEPTION 'Continuity check failed: Last arrival airport (ID=%) does not match current departure airport (ID=%)',
                            last_flight.arrival_airport_id, new_flight.departure_airport_id;
        END IF;
    END IF;

    -- Insert the new scheduled flight into the database
    INSERT INTO airline_booking2.scheduled_flight (
        departure_time,
        arrival_time,
        plane_id,
        departure_airport_id,
        arrival_airport_id,
        overbooking_id
    )
    VALUES (
        new_flight.departure_time,
        new_flight.arrival_time,
        new_flight.plane_id,
        new_flight.departure_airport_id,
        new_flight.arrival_airport_id,
        new_flight.overbooking_id
    );
END;
$$;

CREATE TYPE scheduled_flight_type AS (
    departure_time timestamp,
    arrival_time timestamp,
    plane_id int,
    departure_airport_id int,
    arrival_airport_id int,
    overbooking_id int
);

CALL insert_scheduled_flight(
    ROW('2024-11-21 08:00'::timestamp, '2024-11-21 10:00'::timestamp, 2, 5, 10, 1)::scheduled_flight_type
);
