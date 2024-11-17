using AirportFlightScheduler.Data;
using Microsoft.EntityFrameworkCore;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace AirportFlightScheduler.GenChain1;

public class FlightDataGenerator
{
    private AirlineContext _context;

    public FlightDataGenerator(AirlineContext context)
    {
        _context = context;
    }

    // Run all of the 
    public async Task<List<int>> GenerateAllData()
    {
        List<int> scheduledFlightIds = await GenerateScheduledFlights();
        List<int> reservationIds = await GenerateReservations(scheduledFlightIds);
        List<int> seatIds = await GenerateSeats(reservationIds);
        List<int> paymentIds = await GeneratePayments(reservationIds);

        return seatIds;
    }

    // Generate a given number of fake passengers
    private async Task<List<int>> GeneratePassengers(int passengerCount)
    {
        List<Passenger> passengers = [];

        // Create all the fake passengers using info from the DataGenerator class
        for (int i = 0; i < passengerCount; i++)
        {
            passengers.Add(new Passenger
            {
                PassengerName = DataGenerator.GeneratePassengerName(),
                PassportId = DataGenerator.GeneratePassportId(),
                Phone = DataGenerator.GeneratePhoneNumber(),
                Email = DataGenerator.GenerateEmail(),
                Address = DataGenerator.GenerateAddress()
            });
        }

        // Add entities to the context, save them, and return the IDs
        await _context.Passengers.AddRangeAsync(passengers);
        await _context.SaveChangesAsync();
        return passengers.Select(entity => entity.Id).ToList();
    }

    // Generate one day worth of flights in the in the ScheduledFlight table
    private async Task<List<int>> GenerateScheduledFlights()
    {
        // Get the latest flight from the ScheduledFlight table
        var latestScheduledFlight = await _context.ScheduledFlights
            .OrderByDescending(f => f.ArrivalTime)
            .FirstOrDefaultAsync();

        // Set the DateTime to 1/1/2017 if no flights are present in the database
        DateTime startOfNextDay = latestScheduledFlight == null
            ? new DateTime(2017, 1, 1)
            : latestScheduledFlight.ArrivalTime.Date.AddDays(1);

        Random rand = new Random();

        // Get list of available planes
        List<Plane> planes = _context.Planes.ToList();

        // Calculate the number of minutes of air time per plane (90% of the 1440 minutes in a day)
        double timePerPlane = 1440 * 0.9;

        // Schedule flights
        List<ScheduledFlight> newFlights = [];
        foreach (var plane in planes)
        {
            var lastFlight = _context.ScheduledFlights
                .Where(f => f.PlaneId == plane.Id)
                .OrderByDescending(f => f.ArrivalTime)
                .FirstOrDefault();

            // Set the earliest flight to start at the beginning of the day, and get the airport it's at currently at (if none, default to Chicago ORD). 
            int planeCurrentLocation = lastFlight?.ArrivalAirportId ?? 4;
            DateTime planeLastArrival = startOfNextDay;
            TimeSpan remainingTime = TimeSpan.FromMinutes(timePerPlane);

            while (remainingTime.TotalMinutes > 0)
            {
                // Filter the flight times for flights that can fit in the remaining time in the day
                var validAirportPairs = DataGenerator.flightTimes
                    .Where(f => f.Key.Item1 == planeCurrentLocation && f.Value <= remainingTime.TotalMinutes)
                    .Select(f => f.Key)
                    .ToList();

                // Ensure there are valid airport pairs to choose from
                if (validAirportPairs.Count == 0)
                {
                    break;
                }

                var randomAirportPair = validAirportPairs.ElementAt(rand.Next(validAirportPairs.Count));
                int flightDuration = DataGenerator.flightTimes[randomAirportPair];

                remainingTime = remainingTime.Subtract(TimeSpan.FromMinutes(flightDuration));
                DateTime departureTime = planeLastArrival;
                DateTime arrivalTime = departureTime.AddMinutes(flightDuration);

                // Create a new scheduled flight
                newFlights.Add(new ScheduledFlight
                {
                    DepartureTime = departureTime,
                    ArrivalTime = arrivalTime,
                    PlaneId = plane.Id,
                    DepartureAirportId = randomAirportPair.Item1,
                    ArrivalAirportId = randomAirportPair.Item2,
                });

                // Update the plane's current location to the arrival airport
                planeCurrentLocation = randomAirportPair.Item2;
            }
        }

        // Add the new flights to the context and save them
        await _context.ScheduledFlights.AddRangeAsync(newFlights);
        await _context.SaveChangesAsync();

        // Return a list of the scheduled flight IDs
        return newFlights.Select(f => f.Id).ToList();
    }

    // Given a list of scheduledFlightIds, generate all the necessary reservations in the reservation table
    private async Task<List<int>> GenerateReservations(List<int> scheduledFlightIds)
    {
        // Validate that the ScheduledFlight IDs exist
        var validFlights = await _context.ScheduledFlights
            .Where(f => scheduledFlightIds.Contains(f.Id))
            .ToListAsync();

        if (validFlights.Count != scheduledFlightIds.Count)
        {
            throw new ArgumentException("Some ScheduledFlight IDs are invalid.");
        }

        // Create reservations
        List<Reservation> reservations = new List<Reservation>();

        foreach (var flight in validFlights)
        {
            // Determine ticket cost based on flight length
            var flightDuration = (flight.ArrivalTime - flight.DepartureTime).TotalMinutes;
            decimal ticketCost = (decimal)flightDuration * 0.15m; // Example cost logic: $0.15 per minute of flight

            // Generate 50 passengers for this flight
            List<int> passengerIds = await GeneratePassengers(50);

            // Create reservations for the generated passengers
            foreach (var passengerId in passengerIds)
            {
                var reservation = new Reservation
                {
                    PassengerId = passengerId,
                    ScheduledFlightId = flight.Id,
                    TicketCost = ticketCost
                };

                reservations.Add(reservation);
            }
        }

        // Save reservations to the database
        await _context.Reservations.AddRangeAsync(reservations);
        await _context.SaveChangesAsync();

        // Return the IDs of the created reservations
        return reservations.Select(f => f.Id).ToList();
    }

    // Given a list of reservationIDs, generate all the necessary seats in the seat table
    private async Task<List<int>> GenerateSeats(List<int> reservationIds)
    {
        // Validate that the reservation IDs exist
        var validReservations = await _context.Reservations
            .Where(r => reservationIds.Contains(r.Id))
            .Include(r => r.Passenger)
            .Include(r => r.ScheduledFlight)
            .ThenInclude(f => f.Plane)
            .ThenInclude(p => p.PlaneType)
            .ToListAsync();

        if (validReservations.Count != reservationIds.Count)
        {
            throw new ArgumentException("Some reservation IDs are invalid.");
        }

        // Get seat types from the database
        var seatTypes = await _context.SeatTypes.ToDictionaryAsync(st => st.SeatType1, st => st.Id);

        // Dictionary to keep track of remaining seats per seat type for each plane type
        var seatAvailabilityByPlaneType = new Dictionary<int, Dictionary<int, int>>();

        // Prepare seats for each reservation
        List<Seat> seats = new List<Seat>();
        Random random = new Random();

        foreach (var reservation in validReservations)
        {
            var plane = reservation.ScheduledFlight.Plane;
            var planeType = plane.PlaneType;

            // Initialize seat availability for this plane type if not already done
            if (!seatAvailabilityByPlaneType.ContainsKey(planeType.Id))
            {
                var planeTypeSeatTypes = await _context.PlaneTypeSeatTypes
                    .Where(ptst => ptst.PlaneTypeId == planeType.Id)
                    .ToListAsync();

                seatAvailabilityByPlaneType[planeType.Id] = planeTypeSeatTypes.ToDictionary(
                    ptst => ptst.SeatTypeId,
                    ptst => ptst.Quantity
                );
            }

            var availability = seatAvailabilityByPlaneType[planeType.Id];

            // Ensure there are available seats across all types
            if (availability.Values.Sum() == 0)
            {
                throw new InvalidOperationException($"Plane type {planeType.Id} is overbooked. No available seats.");
            }

            // Assign a seat type that still has availability
            int seatType = availability
                .Where(kv => kv.Value > 0)
                .OrderBy(_ => random.Next())
                .Select(kv => kv.Key)
                .First();

            // Assign the next seat number in sequence
            int seatNumber = seatAvailabilityByPlaneType[planeType.Id].Values.Sum() - availability.Values.Sum() + 1;

            seats.Add(new Seat
            {
                ReservationId = reservation.Id,
                PassengerId = reservation.PassengerId,
                SeatTypeId = seatType,
                SeatNumber = seatNumber,
                PrintedBoardingPassAt = reservation.ScheduledFlight.DepartureTime.AddHours(-1)
            });

            // Reduce the seat count for the chosen type
            availability[seatType]--;
        }

        // Save the seat assignments to the database
        await _context.Seats.AddRangeAsync(seats);
        await _context.SaveChangesAsync();

        // Return the ids of the created seats
        return seats.Select(f => f.Id).ToList();
    }


    // Given a list of reservationIDs, generate all the necessary payments in the payment table
    public async Task<List<int>> GeneratePayments(List<int> reservationIds)
    {
        var reservations = _context.Reservations
            .Where(r => reservationIds.Contains(r.Id))
            .ToList();

        List<Payment> payments = reservations.Select(r => new Payment
        {
            ReservationId = r.Id,
            Amount = r.TicketCost,
        }).ToList();

        _context.Payments.AddRange(payments);
        await _context.SaveChangesAsync();

        // Return the ids of the created payments
        return payments.Select(f => f.Id).ToList();
    }
}
