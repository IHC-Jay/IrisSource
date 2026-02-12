using System;
using System.Collections.Generic;
using System.Text;

namespace RdpValidationRestApi.Util
{
    public static class NpiValidator
    {
        /// <summary>
        /// Validates a National Provider Identifier (NPI).
        /// - Exactly 10 numeric digits (9-digit identifier + 1 check digit)
        /// - Check digit is Luhn mod-10 computed on the 9-digit base with +24 constant
        /// - Optional: enforce first digit is 1 or 2 (issuance guidance)
        /// </summary>
        public static bool IsValidNpi(string npi, bool enforceLeading12 = true)
        {
            if (string.IsNullOrWhiteSpace(npi)) return false;
            if (npi.Length != 10) return false;

            for (int i = 0; i < npi.Length; i++)
            {
                if (npi[i] < '0' || npi[i] > '9') return false;
            }

            if (enforceLeading12 && npi[0] != '1' && npi[0] != '2')
                return false;

            int computed = ComputeNpiCheckDigit(npi.AsSpan(0, 9));
            int provided = npi[9] - '0';
            return computed == provided;
        }

        /// <summary>
        /// Computes the NPI check digit using Luhn mod-10 with the +24 constant
        /// (equivalent to computing as if the 80840 prefix were present).
        /// </summary>
        private static int ComputeNpiCheckDigit(ReadOnlySpan<char> nineDigits)
        {
            int total = 24; // per NPI spec
            for (int i = nineDigits.Length - 1, posFromRight = 1; i >= 0; i--, posFromRight++)
            {
                int d = nineDigits[i] - '0';
                if ((posFromRight & 1) == 1)
                {
                    int twice = d * 2;
                    total += (twice / 10) + (twice % 10);
                }
                else
                {
                    total += d;
                }
            }
            int mod = total % 10;
            return (10 - mod) % 10;
        }
    }
}
