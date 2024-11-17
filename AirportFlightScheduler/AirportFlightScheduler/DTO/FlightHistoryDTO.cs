namespace AirportFlightScheduler.DTO;

public class FlightHistoryDTO
{
    public int ScheduledFlightId { get; set; }

    public int PlaneId { get; set; }

    public DateTime? ActualDepartureTime { get; set; }

    public DateTime? ActualArrivalTime { get; set; }
}
