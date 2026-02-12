using System;
using System.Globalization;

namespace RdpValidationRestApi.Util
{

public static class DtpValidator
{

    /// <summary>
    /// Validates X12 dates in D8 (CCYYMMDD) or RD8 (CCYYMMDD-CCYYMMDD) format.
    /// Rules:
    ///  • Dates must be real calendar dates (leap-year aware).
    ///  • Each date must be within [today - 110 years, today], inclusive.
    ///  • No future dates.
    ///  • For RD8, Start ≤ End.
    /// </summary>
    /// <param name="format">D8 or RD8.</param>
    /// <param name="value">Date text (e.g., "20240229" or "20100101-20101231").</param>
    public static bool IsValid(string format, string value)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        var lowerBound = today.AddYears(-10);
        var higherBound = today.AddYears(+10);

        bool InWindow(DateOnly d) => d >= lowerBound && d <= higherBound;

        static bool TryParseCcyyMmDd(string s, out DateOnly date) =>
            DateOnly.TryParseExact(s, "yyyyMMdd", CultureInfo.InvariantCulture,
                                   DateTimeStyles.None, out date);

        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        if (format == "D8")
        {
            if (value.Length != 8)
                return false;

            if (!TryParseCcyyMmDd(value, out var d))
                return false;

            if (!InWindow(d))
                return false;

            return true;
        }
        else // RD8
        {
            var parts = value.Split('-');
            if (parts.Length != 2)
                return false;

            if (parts[0].Length != 8 || parts[1].Length != 8)
                return false;

            if (!TryParseCcyyMmDd(parts[0], out var start))
                return false;

            if (!TryParseCcyyMmDd(parts[1], out var end))
                return false;

            if (start > end)
                return false;

            if (!InWindow(start) || !InWindow(end))
            {
                return false;
            }

            return true;
        }
    }
}
}
