using System;
using System.Globalization;

namespace RdpValidationRestApi.Util
{

public static class EinValidator
{
    public static bool IsValid(string v)
    {
     	if (string.IsNullOrWhiteSpace(v)) return false;
        var digits = new string(v.Where(char.IsDigit).ToArray());
        if (digits.Length != 9)
                return false;
        if (digits.StartsWith("00"))
                return false;
        return true;

    }
}
}
