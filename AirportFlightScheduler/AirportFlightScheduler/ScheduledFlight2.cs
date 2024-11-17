namespace AirportFlightScheduler;

public class ScheduledFlight2
{
    private int planeId;
    public int PlaneId
    {
        get => planeId;
        set
        {
            if (value < 21 && value > 0)
            {
                planeId = value;
            }
            else
            {
                throw new ArgumentException("The plane ID must be between 1 and 20 inclusive.");
            };
        }
    }

    private int departureAirportId;
    public int DepartureAirportId
    {
        get => departureAirportId;
        set
        {
            if (value < 11 && value > 0)
            {
                departureAirportId = value;
            }
            else
            {
                throw new ArgumentException("Invalid airport ID number.");
            };
        }
    }

    private int arrivalAirportId;
    public int ArrivalAirportId
    {
        get => arrivalAirportId;
        set
        {
            if (value < 11 && value > 0)
            {
                arrivalAirportId = value;
            }
            else
            {
                throw new ArgumentException("Invalid airport ID number.");
            };
        }
    }

    private int timeIntervalHours;
    public int TimeIntervalHours
    {
        get => timeIntervalHours;
        set
        {
            if (value > 0)
            {
                timeIntervalHours = value;
            }
            else
            {
                throw new ArgumentException("Time interval hours cannot be negative.");
            };
        }
    }

    private int timeIntervalMinutes;
    public int TimeIntervalMinutes
    {
        get => timeIntervalMinutes;
        set
        {
            if (value > 0)
            {
                timeIntervalMinutes = value;
            }
            else
            {
                throw new ArgumentException("Time interval minutes cannot be negative.");
            };
        }
    }

    private DateTime startTime;
    public DateTime StartTime
    {
        get => startTime;
        set
        {
            startTime = value;
        }
    }
}