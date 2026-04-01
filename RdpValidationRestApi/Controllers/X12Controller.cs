using InterSystems.Data.IRISClient;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RDPCrystalEDILibrary;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace RdpValidationRestApi.Controllers
{
    [ApiController]
    [Route("X12")]
    public class X12Controller : ControllerBase
    {
        private class X12PostRequest
        {
            public string? operation { get; set; }
            public string? filePath { get; set; }
            public string? fileName { get; set; }
            public string? rulesPath { get; set; }
            public string? rulesFile { get; set; }
            public string? transaction { get; set; }
            public string? sessionId { get; set; }
            public int? snipLevel { get; set; }
            public string? X12Id { get; set; }
            public string? nameSpace { get; set; }
            public string? ignoreSegments { get; set; }
            public string? x12String { get; set; }
            public int? logToDb { get; set; }
        }

        [HttpGet]
        public IActionResult Get([FromQuery] string operation, [FromQuery] string? filePath, [FromQuery] string? fileName, [FromQuery] string? rulesPath, string? rulesFile, [FromQuery] string? transaction, string? sessionId, [FromQuery] int? snipLevel, [FromQuery] string? X12Id, [FromQuery] string? nameSpace, [FromQuery] string? ignoreSegments, [FromQuery] string? x12String, [FromQuery] int? logToDb)
        {
            return ProcessRequest(operation, filePath, fileName, rulesPath, rulesFile, transaction, sessionId, snipLevel, X12Id, nameSpace, ignoreSegments, x12String, logToDb);
        }

        [HttpPost]
        public async Task<IActionResult> Post()
        {
            X12PostRequest requestData = await GetPostRequestFromBodyAsync(Request);

            if (string.Equals(requestData.operation, "RDP", StringComparison.OrdinalIgnoreCase)
                && string.IsNullOrWhiteSpace(requestData.transaction))
            {
                return new OkObjectResult(new
                {
                    Results = "POST body requires 'transaction' for operation='RDP'. For text/plain, include a valid ST segment (for example ST*270) so transaction can be inferred, or send JSON with transaction."
                });
            }

            return ProcessRequest(
                requestData.operation ?? string.Empty,
                requestData.filePath,
                requestData.fileName,
                requestData.rulesPath,
                requestData.rulesFile,
                requestData.transaction,
                requestData.sessionId,
                requestData.snipLevel,
                requestData.X12Id,
                requestData.nameSpace,
                requestData.ignoreSegments,
                requestData.x12String,
                requestData.logToDb
            );
        }

        private IActionResult ProcessRequest(string operation, string? filePath, string? fileName, string? rulesPath, string? rulesFile, string? transaction, string? sessionId, int? snipLevel, string? X12Id, string? nameSpace, string? ignoreSegments, string? x12String, int? logToDb)
        {
            var irisObj = new IrisDb();
            string retStr = "";
            string dataFile = "";
            int snipVal = 0;
            int logIris = 1;

            DateTime currentDateTime = DateTime.Now;
            string logFile = "/itf-testdata/rdp/console/logs/Rdp-" + currentDateTime.ToString("yyyyMMdd") + ".log";

            System.IO.File.WriteAllText(logFile, "In X12Controller " + operation + ", " + transaction + ", " + currentDateTime.ToString("yyyyMMdd-HHmmss"));

            if (snipLevel != null)
            {
                snipVal = snipLevel.Value;
            }
            if (logToDb != null)
            {
                logIris = logToDb.Value;
            }

            if (filePath != null && filePath != "")
            {
                if (!System.IO.Directory.Exists(filePath))
                {
                    return new OkObjectResult(new { Results = "File Directory does not exists:" + filePath });
                }
            }

            if (rulesPath != null && rulesPath != "")
            {
                if (!System.IO.Directory.Exists(rulesPath))
                {
                    return new OkObjectResult(new { Results = "Rules Directory does not exists:" + rulesPath });
                }
            }

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                System.IO.File.AppendAllText(logFile, ", Running on Windows.");
                if (rulesPath == null || rulesPath == "")
                {
                    rulesPath = "C:\\temp\\ihcRdpRules\\";
                }
                if (filePath == null || filePath == "")
                {
                    filePath = "c:\\Temp\\";
                }
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                System.IO.File.AppendAllText(logFile, ", Running on Linux.");

                if (rulesPath == null || rulesPath == "")
                {
                    rulesPath = "/itf-share/itf-tmp/RdpCrystal/Rules/";
                }

                if (filePath == null || filePath == "")
                {
                    filePath = "/itf-share/itf-tmp/RdpCrystal/Data/";
                }
            }

            if (operation == "RDP" && transaction == null)
            {
                return new OkObjectResult(new { Results = "Transaction is required for operation=RDP" });
            }

            if (operation == "RDP" && transaction != null)
            {
                System.IO.File.AppendAllText(logFile, ", validate: " + transaction);
                if ((fileName == null || fileName == "") && string.IsNullOrWhiteSpace(x12String))
                {
                    return new OkObjectResult(new { Results = "Provide X12 as request body (application/json or text/plain) when fileName is not provided." });
                }

                if ((fileName == null || fileName == "") && !string.IsNullOrWhiteSpace(x12String))
                {
                    if (x12String.Length < 108)
                    {
                        return new OkObjectResult(new { Results = "X12 string can't be less than 108 bytes. " + x12String });
                    }
                    System.IO.File.AppendAllText(logFile, ", Create a file with x12String, length: " + x12String.Length);
                    dataFile = Path.Combine(filePath, "x12-" + currentDateTime.ToString("yyyyMMdd-HHmmss") + ".txt");
                    try
                    {
                        System.IO.File.WriteAllText(dataFile, x12String);
                    }
                    catch (IOException e)
                    {
                        System.IO.File.AppendAllText(logFile, ", An error occurred in file " + dataFile + ", write: " + e.Message);
                    }
                    if (!System.IO.File.Exists(dataFile))
                    {
                        return new OkObjectResult(new { Results = "X12 file could not be created " + dataFile + " for X12 string" });
                    }
                }
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    if (fileName != null && fileName.Contains('\\'))
                    {
                        dataFile = fileName;
                    }
                    else
                    {
                        dataFile = Path.Combine(filePath + fileName);
                    }
                }
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                {
                    if (fileName != null && fileName.Contains('/'))
                    {
                        dataFile = fileName;
                    }
                    else
                    {
                        dataFile = Path.Combine(filePath + fileName);
                    }
                }
                System.IO.File.AppendAllText(logFile, ", X12 data file: " + dataFile);
                System.IO.File.AppendAllText(logFile, ", Rule file: " + rulesFile);
                if (!System.IO.File.Exists(dataFile))
                {
                    return new OkObjectResult(new { Results = "Data file does not exists:" + dataFile });
                }

                var obj = new RdpValidate();
                System.IO.File.AppendAllText(logFile, ", Call RdpValidate ProcessX12");
                X12Response rdpResp = obj.ProcessX12(dataFile, transaction, rulesPath, rulesFile, snipVal, ignoreSegments);
                if (rdpResp.validator != null)
                {
                    retStr = irisObj.RdpErrorsToIris(nameSpace, rdpResp.validator, fileName, (sessionId == null) ? "" : sessionId, rdpResp.ackStr, logIris);
                    System.IO.File.AppendAllText(logFile, ", Skip RdpErrorsToIris: " + logIris);
                    retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count + ";";
                    foreach (EDIError error in rdpResp.validator.Errors)
                    {
                        retStr += "Line: " + error.LineNumber + ", ValidatingSegment: " + error.ValidatingSegment.ToString() + ", Loop: " + error.Loop + ", Segment: " + error.Segment + ", Ordinal: " + error.ElementOrdinal.ToString() + ", Snip: " + error.SnipLevel.ToString() + ", Details: " + error.Message.ToString() + ", " + error.Description + ";";
                    }
                }
		if (logIris == 1)
		{
                     	System.IO.File.AppendAllText(logFile, ", return: " + retStr);
                     	retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count + ". Details are stored in IHC_ITF_ITFCOMMON_X12.RdpValidationErrors";
		}

                if (rdpResp.ackStr != null && rdpResp.ackStr.Length > 2056)
                {
                    rdpResp.ackStr = rdpResp.ackStr.Substring(0, 2056);
                }

                return new OkObjectResult(new { Transaction = transaction, FileName = fileName, Status = rdpResp.status, Details = retStr, ACK = rdpResp.ackStr });
            }
            else if (operation == "IRIS" && X12Id != null && transaction != null)
            {
                var flNm = irisObj.GetX12Data(nameSpace, X12Id, transaction, filePath);
                return new OkObjectResult(new { Results = $"{transaction} X12 date, ID: {X12Id} is stored in {flNm}" });
            }
            else if (operation == "Validate" && transaction != null)
            {
                if (X12Id != null && X12Id != "")
                {
                    Console.WriteLine("Process IRIS X12 data from file: " + irisObj.ToString());
                    var x12Data = irisObj.GetX12Data(nameSpace, X12Id, transaction, filePath);
                    if (x12Data != "")
                    {
                        if (x12Data.Contains("005010X223A2"))
                        {
                            transaction = "837I";
                        }
                        else if (x12Data.Contains("005010X222A1"))
                        {
                            transaction = "837P";
                        }
                        else if (x12Data.Contains("005010X224A2"))
                        {
                            transaction = "837D";
                        }

                        var obj = new RdpValidate();
                        X12Response rdpResp = obj.ProcessX12(x12Data, transaction, rulesPath, rulesFile, snipVal, ignoreSegments);

                        if (rdpResp.validator != null)
                        {
                            retStr = irisObj.RdpErrorsToIris(nameSpace, rdpResp.validator, fileName, (sessionId == null) ? "" : sessionId, rdpResp.ackStr, logIris);
                        }
                        return new OkObjectResult(new { Transaction = transaction, FileName = fileName, Status = rdpResp.status, Details = retStr, ACK = rdpResp.ackStr });
                    }
                    else
                    {
                        return new OkObjectResult(new { Transaction = transaction, ID = X12Id, Status = "FAIL, ID not found in IRIS" });
                    }
                }
                else
                {
                    Console.WriteLine("Process X12 data rows from Table: " + transaction);
                    var outStr = irisObj.ProcessX12Table(nameSpace, transaction, filePath, rulesPath, rulesFile, snipVal);
                    return new OkObjectResult(new { Results = $"{outStr} files processed of transaction type: {transaction}" });
                }
            }
            else if (operation != "")
            {
                Console.WriteLine("Hello " + operation + ", " + fileName);
                var response = new X12Response
                {
                    dataFile = $"Hello, {operation}!",
                    ackStr = $"{fileName}",
                    status = "success"
                };

                return Ok(response);
            }
            else
            {
                return Ok(new { Results = $"Hello, World" });
            }
        }

        private static async Task<X12PostRequest> GetPostRequestFromBodyAsync(HttpRequest request)
        {
            var postRequest = new X12PostRequest();

            if (request.Body == null || !request.Body.CanRead)
            {
                return postRequest;
            }

            string body;
            using (var reader = new StreamReader(request.Body, Encoding.UTF8, true, leaveOpen: true))
            {
                body = await reader.ReadToEndAsync();
            }

            if (request.Body.CanSeek)
            {
                request.Body.Position = 0;
            }

            if (string.IsNullOrWhiteSpace(body))
            {
                return postRequest;
            }

            string contentType = request.ContentType?.Split(';')[0].Trim().ToLowerInvariant() ?? string.Empty;
            bool isJson = contentType == "application/json" || contentType.EndsWith("+json");
            bool isPlainText = contentType == "text/plain";

            if (isPlainText)
            {
                postRequest.operation = "RDP";
                postRequest.x12String = body;
                postRequest.transaction = InferTransactionFromX12(body);
                return postRequest;
            }

            if (!isJson)
            {
                string trimmedBody = body.TrimStart();
                if (!(trimmedBody.StartsWith("{") || trimmedBody.StartsWith("\"")))
                {
                    postRequest.operation = "RDP";
                    postRequest.x12String = body;
                    postRequest.transaction = InferTransactionFromX12(body);
                    return postRequest;
                }
            }

            try
            {
                using JsonDocument json = JsonDocument.Parse(body);
                JsonElement root = json.RootElement;

                if (root.ValueKind == JsonValueKind.String)
                {
                    postRequest.operation = "RDP";
                    postRequest.x12String = root.GetString();
                    postRequest.transaction = InferTransactionFromX12(postRequest.x12String ?? string.Empty);
                    return postRequest;
                }

                if (root.ValueKind == JsonValueKind.Object)
                {
                    postRequest = JsonSerializer.Deserialize<X12PostRequest>(body, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    }) ?? new X12PostRequest();

                    if (root.TryGetProperty("x12", out JsonElement x12Element) && x12Element.ValueKind == JsonValueKind.String)
                    {
                        postRequest.x12String = x12Element.GetString();
                    }

                    return postRequest;
                }
            }
            catch
            {
                if (isJson)
                {
                    return postRequest;
                }

                postRequest.operation = "RDP";
                postRequest.x12String = body;
                postRequest.transaction = InferTransactionFromX12(body);
                return postRequest;
            }

            return postRequest;
        }

        private static string? InferTransactionFromX12(string x12)
        {
            if (string.IsNullOrWhiteSpace(x12))
            {
                return null;
            }

            Match match = Regex.Match(x12, @"(?:^|~)ST\*([^*~]+)", RegexOptions.IgnoreCase);
            if (match.Success && match.Groups.Count > 1)
            {
                return match.Groups[1].Value;
            }

            return null;
        }
    }
}
