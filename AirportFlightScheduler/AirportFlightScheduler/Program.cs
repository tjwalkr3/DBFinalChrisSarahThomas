static void Main(string[] args)
{
    string? userInput;
    bool batch = true;

    Console.WriteLine("Batch? (y/n)");
    userInput = Console.ReadLine();
    // Get y/n answer
    while (userInput.ToLower() != "y" && userInput.ToLower() != "n")
    {
        Console.WriteLine("Sorry, invalid input. Please try again.");
        Console.WriteLine("Batch? (y/n)");
        userInput = Console.ReadLine();
    } 

    // Set batch preference
    if (userInput.ToLower() == "y")
    {
        batch = true;
    }
    else if (userInput.ToLower() == "n")
    {
        batch = false;
    }
}