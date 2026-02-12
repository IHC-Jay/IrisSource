using System;
using System.Text.RegularExpressions;

namespace RdpValidationRestApi.Util
{


public static class SsnValidator
{
    // Matches: 
    //   - 3 digits not 000/666/9xx
    //   - optional dashes at the right places
    //   - group not 00, serial not 0000
    private static readonly Regex SsnRegex = new(
        @"^(?!000|666|9\d{2})\d{3}(-?)(?!00)\d{2}\1(?!0000)\d{4}$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    /// <summary>
    /// Validates whether the provided value is a valid SSN by format and known assignment rules.
    /// Accepts "AAA-GG-SSSS" or "AAAGGSSSS".
    /// </summary>
    public static bool IsValid(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return false;

        // Fast path: reject any characters other than digits and dashes
        foreach (char c in value)
        {
            if (!(char.IsDigit(c) || c == '-')) return false;
        }

        return SsnRegex.IsMatch(value);
    }

    /// <summary>
    /// Attempts to normalize to dash format "AAA-GG-SSSS".
    /// Returns false if input is not a valid SSN.
    /// </summary>
    public static bool TryNormalizeDashed(string? value, out string normalized)
    {
        normalized = string.Empty;
        if (!IsValid(value)) return false;

        // strip dashes if present, reformat consistently
        string digits = ExtractDigits(value!);
        normalized = $"{digits.Substring(0, 3)}-{digits.Substring(3, 2)}-{digits.Substring(5, 4)}";
        return true;
    }

    /// <summary>
    /// Attempts to normalize to 9-digit format "AAAGGSSSS" (no dashes).
    /// Returns false if input is not a valid SSN.
    /// </summary>
    public static bool TryNormalizeDigits(string? value, out string normalized)
    {
        normalized = string.Empty;
        if (!IsValid(value)) return false;

        normalized = ExtractDigits(value!);
        return true;
    }

    /// <summary>
    /// Returns the reason an SSN is invalid (best-effort).
    /// Useful for logging or UI hints. Do not log raw SSNs—use masked versions.
    /// </summary>
    public static bool TryGetFailureReason(string? value, out string reason)
    {
        reason = string.Empty;
        if (string.IsNullOrWhiteSpace(value))
        {
            reason = "Empty value.";
            return false;
        }

        foreach (char c in value)
        {
            if (!(char.IsDigit(c) || c == '-'))
            {
                reason = "Contains invalid characters (only digits and optional dashes allowed).";
                return false;
            }
        }

        string digits = ExtractDigits(value);

        if (digits.Length != 9)
        {
            reason = "Must contain exactly 9 digits.";
            return false;
        }

        string area = digits[..3];
        string group = digits.Substring(3, 2);
        string serial = digits.Substring(5, 4);

        if (area == "000") { reason = "Area cannot be 000."; return false; }
        if (area == "666") { reason = "Area cannot be 666."; return false; }
        if (area[0] == '9') { reason = "Area 900–999 are invalid for SSNs."; return false; }

        if (group == "00") { reason = "Group cannot be 00."; return false; }
        if (serial == "0000") { reason = "Serial cannot be 0000."; return false; }

        // Check dash placement if present (must be AAA-GG-SSSS or no dashes)
        if (value!.Contains('-') && !SsnRegex.IsMatch(value))
        {
            reason = "Incorrect dash placement—use AAA-GG-SSSS.";
            return false;
        }

        return true;
    }

    /// <summary>
    /// Masks an SSN for display/logging as ***-**-1234 (or ********* if only digits).
    /// Works regardless of original formatting.
    /// </summary>
    public static string Mask(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return string.Empty;

        string digits = ExtractDigits(value);
        if (digits.Length != 9) return "*********";
        return $"***-**-{digits.Substring(5, 4)}";
    }

    private static string ExtractDigits(string value)
    {
        Span<char> buffer = stackalloc char[value.Length];
        int j = 0;
        foreach (char c in value)
        {
            if (char.IsDigit(c)) buffer[j++] = c;
        }
        return new string(buffer[..j]);
    }
}
}
