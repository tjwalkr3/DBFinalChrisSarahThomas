using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AirportFlightScheduler
{
    public static class DateTimeFormatter
    {
        public static string GetFormattedDateTimeAsString(DateTime dateTimeToFormat)
        {
            string formattedDateTime = dateTimeToFormat.ToString(Constants.DateTimeFormat);
            return formattedDateTime;
        }
    }
}
