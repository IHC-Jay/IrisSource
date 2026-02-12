using System;
using System.IO;
using System.Text;
using Microsoft.VisualBasic.FileIO;


namespace RdpValidationRestApi.Util
{

public static class CsvLookup
{
    /// <summary>
    /// Looks up a row by key in the first column of a CSV file and returns the second column's value.
    /// </summary>
    /// <param name="csvPath">Path to the CSV file.</param>
    /// <param name="key">Key value to match in column 0.</param>
    /// <param name="delimiter">Field delimiter (default ",").</param>
    /// <param name="hasHeader">Skip the first line if true (default false).</param>
    /// <param name="ignoreCase">Case-insensitive key comparison (default true).</param>
    /// <param name="encoding">Text encoding (default UTF8).</param>
    /// <returns>The second column value if a matching key is found; otherwise null.</returns>
    public static string? GetSecondValueByKey(
        string csvPath,
        string key,
        string delimiter = ",",
        bool hasHeader = false,
        bool ignoreCase = true,
        Encoding? encoding = null)
    {
        if (csvPath is null) throw new ArgumentNullException(nameof(csvPath));
        if (key is null) throw new ArgumentNullException(nameof(key));
        if (!File.Exists(csvPath)) throw new FileNotFoundException("CSV file not found.", csvPath);

        var comparison = ignoreCase ? StringComparison.OrdinalIgnoreCase : StringComparison.Ordinal;

        // Default to UTF8 if not provided
        encoding ??= Encoding.UTF8;

        using var stream = new FileStream(csvPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
        using var reader = new StreamReader(stream, encoding, detectEncodingFromByteOrderMarks: true);
        using var parser = new TextFieldParser(reader);

        parser.SetDelimiters(delimiter);
        parser.HasFieldsEnclosedInQuotes = true;
        parser.TrimWhiteSpace = false;

        if (hasHeader && !parser.EndOfData)
        {
            // Consume header row
            _ = parser.ReadFields();
        }

        while (!parser.EndOfData)
        {
            var fields = parser.ReadFields();
            if (fields is null || fields.Length < 2) continue; // need at least two columns

            var candidateKey = fields[0] ?? string.Empty;
            if (candidateKey.Equals(key, comparison))
            {
                return fields[1]; // second column
            }
        }

        return null; // not found
    }
}
}
