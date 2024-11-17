namespace AirportFlightScheduler.DTO;

public class ReservationDTO
{
    public int PassengerId { get; set; }

    public int ScheduledFlightId { get; set; }

    public decimal TicketCost { get; set; }
}
