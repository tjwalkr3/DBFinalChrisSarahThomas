using AirportFlightScheduler.Data;
using Microsoft.EntityFrameworkCore;

namespace AirportFlightScheduler.GenChain1;

public class FlightDataGenerator
{
    private AirlineContext _context;

    public FlightDataGenerator(AirlineContext context)
    {
        _context = context;
    }

    private async Task<List<int>> GeneratePassengers(int passengerCount)
    {
        List<Passenger> passengers = [];

        // Create DTOs
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


    // I know this method is way too long. 
    private async Task<List<int>> GenerateScheduledFlights()
    {
        // Get the latest flight time from the ScheduledFlight table
        var latestScheduledFlight = await _context.ScheduledFlights
            .OrderByDescending(f => f.ArrivalTime)
            .FirstOrDefaultAsync();

        DateTime startOfNextDay = latestScheduledFlight == null ? DateTime.Today.AddDays(1) : latestScheduledFlight.ArrivalTime.Date.AddDays(1);

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

            // Get the last location and time.  If the plane has no previous flight, assume it's at Chicago ORD at the start of the day.
            int planeCurrentLocation = lastFlight?.ArrivalAirportId ?? 4;
            DateTime planeLastArrival = lastFlight?.ArrivalTime ?? startOfNextDay;
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

                var randomAirportPair = validAirportPairs.ElementAt(new Random().Next(validAirportPairs.Count));
                int flightDuration = DataGenerator.flightTimes[randomAirportPair];

                remainingTime = remainingTime.Subtract(TimeSpan.FromMinutes(flightDuration));
                DateTime departureTime = planeLastArrival; // use .AddMinutes() here to add a delay between each flight
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
}
