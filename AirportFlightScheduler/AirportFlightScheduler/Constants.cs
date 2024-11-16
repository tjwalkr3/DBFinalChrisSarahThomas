using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace AirportFlightScheduler
{
    public static class Constants
    {
        public const int OverbookingRateId = 1;
        public const string DateTimeFormat = "yyyy-MM-dd HH:mm:ss";
        public static readonly List<int> ValidPlaneIds = new List<int>() { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
        public static readonly List<string> ValidAirportIds = new List<string>() 
        {
            "JFK",
            "LAX",
            "SEA",
            "ORD",
            "MDW",
            "SFO",
            "SLC",
            "DEN",
            "AGS",
            "ANC"
        };
    }
}
