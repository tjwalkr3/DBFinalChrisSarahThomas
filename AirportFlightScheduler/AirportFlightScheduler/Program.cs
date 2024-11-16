// Main driver for console creation of queries to insert into scheduled_flight
using Microsoft.Extensions.Configuration;
using AirportFlightScheduler;
using Microsoft.EntityFrameworkCore;
using AirportFlightScheduler.Data;

public class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Hello, world!");

        // Load configuration (including User Secrets)
        var configuration = new ConfigurationBuilder()
            .AddUserSecrets<Program>() // Enable User Secrets
            .Build();

        // Retrieve the connection string
        var connectionString = configuration.GetConnectionString("DefaultConnection");

        // Create DbContext options
        var options = new DbContextOptionsBuilder<AirlineContext>()
            .UseNpgsql(connectionString)
            .Options;

        // Use the DbContext
        using var context = new AirlineContext(options);
        Console.WriteLine("DbContext configured and ready to use!");

        string? userInput;
        bool batch = true;
        int planeId = 0;

        // Ask whether the user wants to create a batch insert query
        userInput = GetValidInput(new List<string> { "y", "n" }, prompt: "Batch? (y/n)");

        // Set batch preference
        if (userInput.ToLower() == "y") batch = true;
        else if (userInput.ToLower() == "n") batch = false;

        // Get plane ID
        string planeIdPrompt = $"Please enter a valid plane ID (should be between 1 and {Constants.ValidPlaneIds.Count}).";
        userInput = GetValidInput(Constants.ValidPlaneIds.ConvertAll<string>(id =>id.ToString()), planeIdPrompt);
    
        // set the plane ID
        try { planeId = Int32.Parse(userInput); }
        // if the catch block ever gets hit it would most likely be due to integer overflow, but I don't know how it could happen given how input is being retrieved via GetValidInput
        catch { Console.WriteLine("There was an error parsing the plane ID. Please contact the developer."); throw new Exception(); } 

    
    }

    /// < summary >
    /// This method allows passing a List of string values that classify as valid inputs, 
    /// a prompt to instruct users on what inputs to give, and a case sensitivity boolean 
    /// that determines whether or not user input must match the case of the valid inputs.
    /// </summary>
    static string GetValidInput(List<string> validInputs, string prompt, bool isCaseSensitive = false)
    {
        string invalidInputMsg = "Sorry, invalid input. Please try again.";
        string userInput = Console.ReadLine();

        if (isCaseSensitive)
        {
            while (!validInputs.Contains(userInput))
            {
                Console.WriteLine(invalidInputMsg);
                Console.WriteLine(prompt);
                userInput = Console.ReadLine();
            }
            return userInput;
        }

        // This code is only run for non-case-sensitive inputs
        List<string> lowercaseValidInputs = validInputs.ConvertAll(item => item.ToLower());
        while (!lowercaseValidInputs.Contains(userInput))
        {
            Console.WriteLine(invalidInputMsg);
            Console.WriteLine(prompt);
            userInput = Console.ReadLine();
        };
        return userInput;
    }
}