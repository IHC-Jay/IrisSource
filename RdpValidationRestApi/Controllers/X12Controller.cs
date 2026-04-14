using InterSystems.Data.IRISClient;
using Microsoft.AspNetCore.Mvc;
using RDPCrystalEDILibrary;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Dynamic;
using System.IO;
using System.IO.Pipelines;
using System.Runtime.InteropServices;
using System.Xml.Linq;


namespace RdpValidationRestApi.Controllers
{
    [ApiController]
    [Route("X12")]

    public class X12Controller : ControllerBase
    {



        [HttpGet]
        public IActionResult Get([FromQuery] string operation, [FromQuery] string? filePath, [FromQuery] string? fileName, [FromQuery] string? rulesPath, string? rulesFile, [FromQuery] string? transaction, string? sessionId, [FromQuery] int? snipLevel, [FromQuery] string? X12Id, [FromQuery] string? nameSpace, [FromQuery] string? ignoreSegments, [FromQuery] string? x12String, [FromQuery] int? logToDb)

        {
            var irisObj = new IrisDb();
            string retStr = "";
            string dataFile = "";
            int snipVal = 0;
            int logIris = 1;

            DateTime currentDateTime = DateTime.Now;
            string logDir = RuntimeInformation.IsOSPlatform(OSPlatform.Windows) ? @"c:\temp" : "/itf-testdata/rdp/console/logs";
            string logFile = Path.Combine(logDir, "Rdp-" + currentDateTime.ToString("yyyyMMdd") + ".log");

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
            // DEFAULT paths
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                System.IO.File.AppendAllText(logFile, "Running on Windows.");
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
                System.IO.File.AppendAllText(logFile, "Running on Linux.");

                if (rulesPath == null || rulesPath == "")
                {
                    rulesPath = "/itf-share/itf-tmp/RdpCrystal/Rules/";
                }

                if (filePath == null || filePath == "")
                {
                    filePath = "/itf-share/itf-tmp/RdpCrystal/Data/";
                }

            }
            // Validate a X12 file and write any errors to IRIS table
            if (operation == "RDP" && transaction != null)
            {
                System.IO.File.AppendAllText(logFile, "Validate: " + transaction);
                if ((fileName == null || fileName == "") && (x12String != null))
                {
                    if (x12String.Length < 108)
                    {
                        return new OkObjectResult(new { Results = "X12 string can't be less than 108 bytes. " + x12String });
                    }
                    System.IO.File.AppendAllText(logFile, "Create a file with x12String, length: " + x12String.Length);
                    dataFile = Path.Combine(filePath, "x12-" + currentDateTime.ToString("yyyyMMdd-HHmmss") + ".txt");
                    try
                    {
                        System.IO.File.WriteAllText(dataFile, x12String);
                    }
                    catch (IOException e)
                    {
                        System.IO.File.AppendAllText(logFile, "An error occurred in file " + dataFile + ", write: " + e.Message);
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
                System.IO.File.AppendAllText(logFile, "X12 data file: " + dataFile);
                System.IO.File.AppendAllText(logFile, "Rule file: " + rulesFile);
                if (!System.IO.File.Exists(dataFile))
                {
                    return new OkObjectResult(new { Results = "Data file does not exists:" + dataFile });
                }

                var obj = new RdpValidate();
                System.IO.File.AppendAllText(logFile, "Call RdpValidate ProcessX12");
                X12Response rdpResp = obj.ProcessX12(dataFile, transaction, rulesPath, rulesFile, snipVal, ignoreSegments);
                if (rdpResp.validator != null)
                {

                    retStr = irisObj.RdpErrorsToIris(nameSpace, rdpResp.validator, fileName, (sessionId == null) ? "" : sessionId, rdpResp.ackStr, logIris);
                    System.IO.File.AppendAllText(logFile, "Skip RdpErrorsToIris: " + logIris);
                    retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count + ";";
                    foreach (EDIError error in rdpResp.validator.Errors)
                    {
                        retStr += "Line: " + error.LineNumber + ", ValidatingSegment: " + error.ValidatingSegment.ToString() + ", Loop: " + error.Loop + ", Segment: " + error.Segment + ", Ordinal: " + error.ElementOrdinal.ToString() + ", Details: " + error.Message.ToString() + ", " + error.Description + ";";
                        // retStr += ", Segment: " + error.ValidatingSegment.ToString() +"; Error: " + error.Message.ToString() +" / " + error.Description;
                    }

                }
                System.IO.File.AppendAllText(logFile, "return: " + retStr);
                if (retStr.Length > 2056)
                {
                    retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count + ". Details are stored in IHC_ITF_ITFCOMMON_X12.RdpValidationErrors";
                }
                if (rdpResp.ackStr != null && rdpResp.ackStr.Length > 2056)
                {
                    rdpResp.ackStr = rdpResp.ackStr.Substring(0, 2056);
                }

                return new OkObjectResult(new { Transaction = transaction, FileName = fileName, Status = rdpResp.status, Details = retStr, ACK = rdpResp.ackStr });
            }

            // Return X12 from a IRIS table
            else if (operation == "IRIS" && X12Id != null && transaction != null)
            {

                var flNm = irisObj.GetX12Data(nameSpace, X12Id, transaction, filePath);

                return new OkObjectResult(new { Results = $"{transaction} X12 date, ID: {X12Id} is stored in {flNm}" });

            }

            // Get X12 from a IRIS table, validate X12 and write errors to Table
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
                            /*
							foreach (EDIError error in rdpResp.validator.Errors)
							{
							   retStr = error.ValidatingSegment.ToString() +", Error: " + error.Message.ToString() +" / " + error.Description;
							}
							Console.WriteLine("Skip RdpErrorsToIris: " + retStr);
							*/

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
            /*
                else if (operation == "Edifecs")
                {
                    OracleDataRetriever.GetDataFromOracle();
                    return new OkObjectResult(new { Results = "Data from Edifecs" });
                }
            */

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


        [HttpPost]
        public IActionResult Post([FromBody] dynamic data)
        {
            return Ok(new { you_sent = data });
        }
    }
}
