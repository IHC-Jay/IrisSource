using System;
using System.IO;
using System.Text;

namespace RdpValidationRestApi.Util
{
    public static class ValueLookup
    {
        /// <summary>
        /// Returns true if the given value exists as a full line in the lookup file.
        /// </summary>
        /// <param name="filePath">Path to the lookup file (one value per line).</param>
        /// <param name="value">Value to search for.</param>
        /// <param name="ignoreCase">Case-insensitive value comparison (default true).</param>
        /// <param name="trimLine">Trim each file line before comparison (default true).</param>
        /// <param name="encoding">Text encoding (default UTF8).</param>
        /// <returns>True when a matching value is found; otherwise false.</returns>
        public static bool ExistsInFile(
            string filePath,
            string value,
            bool ignoreCase = true,
            bool trimLine = true,
            Encoding? encoding = null)
        {
            if (filePath is null) throw new ArgumentNullException(nameof(filePath));
            if (value is null) throw new ArgumentNullException(nameof(value));
            if (!File.Exists(filePath)) throw new FileNotFoundException("Lookup file not found.", filePath);

            var comparison = ignoreCase ? StringComparison.OrdinalIgnoreCase : StringComparison.Ordinal;
            var expected = trimLine ? value.Trim() : value;

            // Default to UTF8 if not provided
            encoding ??= Encoding.UTF8;

            using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            using var reader = new StreamReader(stream, encoding, detectEncodingFromByteOrderMarks: true);

            string? line;
            while ((line = reader.ReadLine()) is not null)
            {
                var candidate = trimLine ? line.Trim() : line;

                // Skip blank lines and comment lines
                if (candidate.Length == 0 || candidate.StartsWith("#", StringComparison.Ordinal))
                {
                    continue;
                }

                if (candidate.Equals(expected, comparison))
                {
                    return true;
                }
            }

            return false;
        }
    }
}
