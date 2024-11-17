namespace AirportFlightScheduler.DTO;

public class ScheduledFlightDTO
{
    public DateTime DepartureTime { get; set; }

    public DateTime ArrivalTime { get; set; }

    public int PlaneId { get; set; }

    public int DepartureAirportId { get; set; }

    public int ArrivalAirportId { get; set; }

    public int OverbookingId { get; set; }
}
