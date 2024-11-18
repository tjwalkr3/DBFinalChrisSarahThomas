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

    // Iterate through the data generations functions a set number of times
    public async Task GenerateData(int iterations, int numPassengers, int numProducts)
    {
        for (int i = 0; i < iterations; i++)
        {
            await GenerateSingleDay(numPassengers, numProducts);
            Console.WriteLine($"Done with day: {i + 1}/{iterations}");
        }
    }

    // Run all of the data generation functions
    private async Task GenerateSingleDay(int numPassengers, int numProducts)
    {
        // Data Generation Chain 1
        List<int> scheduledFlightIds = await GenerateScheduledFlights();
        List<int> flightHistoryIds = await GenerateFlightHistory(scheduledFlightIds);
        List<int> reservationIds = await GenerateReservations(scheduledFlightIds, numPassengers);
        List<int> seatIds = await GenerateSeats(reservationIds);
        List<int> paymentIds = await GeneratePayments(reservationIds);

        // Data Generation Chain 2 (A LOT SIMPLER)
        await GenerateConcessionPurchases(seatIds, numProducts);
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
                PassengerName = PlaceholderData.GeneratePassengerName(),
                PassportId = PlaceholderData.GeneratePassportId(),
                Phone = PlaceholderData.GeneratePhoneNumber(),
                Email = PlaceholderData.GenerateEmail(),
                Address = PlaceholderData.GenerateAddress()
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
                var validAirportPairs = PlaceholderData.flightTimes
                    .Where(f => f.Key.Item1 == planeCurrentLocation && f.Value <= remainingTime.TotalMinutes)
                    .Select(f => f.Key)
                    .ToList();

                // Ensure there are valid airport pairs to choose from
                if (validAirportPairs.Count == 0)
                {
                    break;
                }

                var randomAirportPair = validAirportPairs.ElementAt(rand.Next(validAirportPairs.Count));
                int flightDuration = PlaceholderData.flightTimes[randomAirportPair];

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
                    OverbookingId = _context.OverbookingRates.Single().Id
                });

                // Update the plane's current location to the arrival airport
                planeCurrentLocation = randomAirportPair.Item2;
                planeLastArrival = departureTime.AddMinutes(flightDuration);
            }
        }

        // Add the new flights to the context and save them
        await _context.ScheduledFlights.AddRangeAsync(newFlights);
        await _context.SaveChangesAsync();

        // Return a list of the scheduled flight IDs
        return newFlights.Select(f => f.Id).ToList();
    }

    // Generate one entry in the flight history for every entry in the scheduled flights
    private async Task<List<int>> GenerateFlightHistory(List<int> scheduledFlightIds)
    {
        var scheduledFlights = _context.ScheduledFlights
            .Where(s => scheduledFlightIds.Contains(s.Id))
            .ToList();

        List<FlightHistory> flightHistoryEntries = scheduledFlights.Select(s => new FlightHistory
        {
            ScheduledFlightId = s.Id,
            PlaneId = s.PlaneId,
            ActualDepartureTime = s.DepartureTime,
            ActualArrivalTime = s.ArrivalTime
        }).ToList();

        _context.FlightHistories.AddRange(flightHistoryEntries);
        await _context.SaveChangesAsync();

        // Return the ids of the created payments
        return flightHistoryEntries.Select(h => h.Id).ToList();
    }

    // Given a list of scheduledFlightIds, generate all the necessary reservations in the reservation table
    private async Task<List<int>> GenerateReservations(List<int> scheduledFlightIds, int numPassengers)
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
            List<int> passengerIds = await GeneratePassengers(numPassengers);

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
    public async Task<List<int>> GenerateSeats(List<int> reservationIds)
    {
        // Validate that the reservation IDs exist and include their related data
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

        // Group reservations by ScheduledFlightId
        var reservationsGroupedByFlight = validReservations
            .GroupBy(r => r.ScheduledFlightId)
            .ToList();

        var createdSeats = new List<Seat>();
        var createdSeatIds = new List<int>();

        foreach (var reservationGroup in reservationsGroupedByFlight)
        {
            var scheduledFlight = reservationGroup.First().ScheduledFlight;
            var plane = scheduledFlight.Plane;
            var planeType = plane.PlaneType;

            // Initialize seat availability for this plane
            var allSeatTypes = await _context.SeatTypes.ToListAsync();
            var planeTypeSeatTypes = await _context.PlaneTypeSeatTypes
                .Where(ptst => ptst.PlaneTypeId == plane.PlaneTypeId)
                .ToListAsync();

            var seatAvailability = allSeatTypes.ToDictionary(
                st => st.Id,
                st => planeTypeSeatTypes.FirstOrDefault(ptst => ptst.SeatTypeId == st.Id)?.Quantity ?? 0
            );

            // Prepare seats for the current flight
            var seatsForFlight = new List<Seat>();
            Random random = new Random();

            foreach (var reservation in reservationGroup)
            {
                // Ensure there are available seats across all types
                if (seatAvailability.Values.Sum() == 0)
                {
                    throw new InvalidOperationException($"Plane {plane.Id} is overbooked. No available seats.");
                }

                // Assign a seat type that still has availability
                int seatType = seatAvailability
                    .Where(kv => kv.Value > 0)
                    .OrderBy(_ => random.Next())
                    .Select(kv => kv.Key)
                    .First();

                // Assign the next seat number in sequence
                int seatNumber = seatsForFlight.Count + 1;

                createdSeats.Add(new Seat
                {
                    ReservationId = reservation.Id,
                    PassengerId = reservation.PassengerId,
                    SeatTypeId = seatType,
                    SeatNumber = seatNumber,
                    PrintedBoardingPassAt = scheduledFlight.DepartureTime.AddHours(-1)
                });

                // Reduce the seat count for the chosen type
                seatAvailability[seatType]--;
            }
        }

        // Save all changes in a single database call
        await _context.Seats.AddRangeAsync(createdSeats);
        await _context.SaveChangesAsync();

        // Return the ids for the seats that were added to the database
        return createdSeats.Select(f => f.Id).ToList(); ;
    }

    // Given a list of reservationIDs, generate all the necessary payments in the payment table
    private async Task<List<int>> GeneratePayments(List<int> reservationIds)
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

    // Given a list of seats, create entries in the payment, concession_purchase, and concession_purchase_product table (for a given products) 
    public async Task GenerateConcessionPurchases(List<int> seatIds, int numProducts)
    {
        // Validate that the seat IDs exist
        var validSeats = await _context.Seats
            .Where(s => seatIds.Contains(s.Id))
            .ToListAsync();

        if (validSeats.Count != seatIds.Count)
        {
            throw new ArgumentException("Some Seat IDs are invalid.");
        }

        // Retrieve all products in one database call
        var products = await _context.Products.ToListAsync();
        if (products.Count < numProducts)
        {
            throw new InvalidOperationException("Not enough products available to fulfill the request.");
        }

        Random random = new Random();
        List<Payment> payments = new List<Payment>();
        List<ConcessionPurchase> concessionPurchases = new List<ConcessionPurchase>();
        List<ConcessionPurchaseProduct> concessionPurchaseProducts = new List<ConcessionPurchaseProduct>();

        foreach (var seat in validSeats)
        {
            // Select `numProducts` random products
            var selectedProducts = products.OrderBy(_ => random.Next()).Take(numProducts).ToList();

            // Calculate the total cost of the products
            decimal totalCost = selectedProducts.Sum(p => p.Price);

            // Create a Payment entry
            var payment = new Payment
            {
                Amount = totalCost,
                ReservationId = seat.ReservationId
            };
            payments.Add(payment);

            // Create a ConcessionPurchase entry and link it to the payment
            var concessionPurchase = new ConcessionPurchase
            {
                SeatId = seat.Id,
                Payment = payment // Link the Payment object directly
            };
            concessionPurchases.Add(concessionPurchase);

            // Add the ConcessionPurchaseProduct entries and link to the ConcessionPurchase
            foreach (var product in selectedProducts)
            {
                concessionPurchaseProducts.Add(new ConcessionPurchaseProduct
                {
                    ConcessionPurchase = concessionPurchase, // Link the ConcessionPurchase object directly
                    ProductId = product.Id,
                    Quantity = 1
                });
            }
        }

        // Bulk add all entities
        await _context.Payments.AddRangeAsync(payments);
        await _context.ConcessionPurchases.AddRangeAsync(concessionPurchases);
        await _context.ConcessionPurchaseProducts.AddRangeAsync(concessionPurchaseProducts);

        // Save all changes in a single database call
        await _context.SaveChangesAsync();
    }
}
