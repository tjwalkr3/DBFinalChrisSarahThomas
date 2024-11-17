namespace AirportFlightScheduler.DTO;

public class SeatDTO
{
    public int ReservationId { get; set; }

    public int SeatTypeId { get; set; }

    public DateTime? PrintedBoardingPassAt { get; set; }

    public int? SeatNumber { get; set; }

    public int? PassengerId { get; set; }
}
