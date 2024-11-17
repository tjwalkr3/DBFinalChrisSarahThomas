// Main driver for console creation of queries to insert into scheduled_flight
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using AirportFlightScheduler.Data;
using AirportFlightScheduler.GenChain1;

public class Program
{
    static async Task Main(string[] args)
    {
        AirlineContext context;

        // Initialize DBContext object
        try
        {
            var configuration = new ConfigurationBuilder().AddUserSecrets<Program>().Build();
            var connectionString = configuration.GetConnectionString("DefaultConnection");
            var options = new DbContextOptionsBuilder<AirlineContext>().UseNpgsql(connectionString).Options;
            context = new AirlineContext(options);
            Console.WriteLine($"DBContext successfully created with connection string: \n{connectionString}\n");
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.ToString());
            return;
        }

        // Ask which entry path the user wants to 
        string DataGenChain = GetValidInput(new List<string> { "1", "2" }, prompt: "Which data generation chain? [1, 2]");

        switch (DataGenChain)
        {
            case "1":
                FlightDataGenerator generator = new(context);
                Console.WriteLine("Generating data...");
                await generator.GenerateAllData();
                Console.WriteLine("Done.");
                break;
            case "2":
                // code block
                break;
            default:
                Console.WriteLine("Invalid choice");
                break;
        }


        //bool batch = true;
        //int planeId = 0;

        //// Ask whether the user wants to create a batch insert query
        //DataGenChain = GetValidInput(new List<string> { "y", "n" }, prompt: "Batch? (y/n)");

        //// Set batch preference
        //if (DataGenChain.ToLower() == "y") batch = true;
        //else if (DataGenChain.ToLower() == "n") batch = false;

        //// Get plane ID
        //string planeIdPrompt = $"Please enter a valid plane ID (should be between 1 and {Constants.ValidPlaneIds.Count}).";
        //DataGenChain = GetValidInput(Constants.ValidPlaneIds.ConvertAll<string>(id =>id.ToString()), planeIdPrompt);

        //// set the plane ID
        //try { planeId = Int32.Parse(DataGenChain); }
        //// if the catch block ever gets hit it would most likely be due to integer overflow, but I don't know how it could happen given how input is being retrieved via GetValidInput
        //catch { Console.WriteLine("There was an error parsing the plane ID. Please contact the developer."); throw new Exception(); } 


    }

    /// < summary >
    /// This method allows passing a List of string values that classify as valid inputs, 
    /// a prompt to instruct users on what inputs to give, and a case sensitivity boolean 
    /// that determines whether or not user input must match the case of the valid inputs.
    /// </summary>
    static string GetValidInput(List<string> validInputs, string prompt, bool isCaseSensitive = false)
    {
        string invalidInputMsg = "Sorry, invalid input. Please try again.";
        Console.WriteLine(prompt);
        string? userInput = Console.ReadLine();

        if (isCaseSensitive)
        {
            while (userInput == null || !validInputs.Contains(userInput))
            {
                Console.WriteLine(invalidInputMsg);
                Console.WriteLine(prompt);
                userInput = Console.ReadLine();
            }
            return userInput;
        }

        // This code is only run for non-case-sensitive inputs
        List<string> lowercaseValidInputs = validInputs.ConvertAll(item => item.ToLower());
        while (userInput == null || !lowercaseValidInputs.Contains(userInput))
        {
            Console.WriteLine(invalidInputMsg);
            Console.WriteLine(prompt);
            userInput = Console.ReadLine();
        };
        return userInput;
    }
}