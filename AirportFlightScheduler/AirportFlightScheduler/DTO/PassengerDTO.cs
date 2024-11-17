namespace AirportFlightScheduler.DTO;

public class PassengerDTO
{
    public string PassengerName { get; set; } = null!;

    public string? PassportId { get; set; }

    public string Phone { get; set; } = null!;

    public string? Email { get; set; }

    public string Address { get; set; } = null!;
}
