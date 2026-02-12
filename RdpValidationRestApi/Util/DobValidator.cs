using System;
using System.Globalization;

namespace RdpValidationRestApi.Util
{

public static class DobValidator
{
    /// <summary>
    /// Validates that an input in CCYYMMDD (yyyyMMdd) format is a real calendar date
    /// and falls within the last 110 years from today's date (inclusive), and not in the future.
    /// </summary>
    /// <param name="ccyyMMdd">Date string in CCYYMMDD format, e.g., "20141225".</param>
    /// <returns>True if valid and within range; otherwise false.</returns>
    public static bool IsValid(string ccyyMMdd)
    {

        if (string.IsNullOrWhiteSpace(ccyyMMdd) || ccyyMMdd.Length != 8)
            return false;

        // Parse strictly as yyyyMMdd with invariant culture
        if (!DateTime.TryParseExact(
                ccyyMMdd,
                "yyyyMMdd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out var dt))
        {
            return false; // not a real calendar date or wrong format
        }

        var today = DateTime.Today; // local "today"; change to UtcNow.Date if you prefer UTC semantics
        var lowerBound = today.AddYears(-110);

        // Must be between [today - 110 years, today], inclusive
        if (dt < lowerBound || dt > today)
            return false;

        return true;
    }
}
}
