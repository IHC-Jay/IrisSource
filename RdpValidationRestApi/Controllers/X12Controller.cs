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
        public IActionResult Get([FromQuery] string operation, [FromQuery] string? filePath, [FromQuery] string? fileName, [FromQuery] string? rulesPath, string? rulesFile, [FromQuery] string? transaction, string? sessionId, [FromQuery] int? snipLevel, [FromQuery] string? X12Id, [FromQuery] string? nameSpace, string? ignoreSegments)
            
        {
            var irisObj = new IrisDb();
            string retStr = "";
            string dataFile = "";
            int snipVal = 0;

            if (snipLevel != null)
            {
                snipVal = snipLevel.Value;
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
                Console.WriteLine("Running on Windows.");
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
                Console.WriteLine("Running on Linux.");

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
                if (fileName == null || fileName == "")
                {
                    return new OkObjectResult(new { Results = "X12 file to validate is required"  });
                }

                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
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
                Console.WriteLine("X12 data file: " + dataFile);
                Console.WriteLine("Rule file: " + rulesFile);
                if (!System.IO.File.Exists(dataFile))
                {
                    return new OkObjectResult(new { Results = "Data file does not exists:" + dataFile });
                }

                var obj = new RdpValidate();
		Console.WriteLine("Call RdpValidate ProcessX12");
                X12Response rdpResp = obj.ProcessX12(dataFile, transaction, rulesPath, rulesFile, snipVal, ignoreSegments);
                if (rdpResp.validator != null)
                {

                    retStr = irisObj.RdpErrorsToIris(nameSpace, rdpResp.validator, fileName, (sessionId ==null)?"":sessionId, rdpResp.ackStr);
		    // Console.WriteLine("Skip RdpErrorsToIris");
    		    retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count ;
		    foreach (EDIError error in rdpResp.validator.Errors)
		    {
			retStr += ", Segment: " + error.ValidatingSegment.ToString() +"; Error: " + error.Message.ToString() +" / " + error.Description;
		    }

                }
		Console.WriteLine("return: " + retStr);
		if (retStr.Length > 2056)
		{
    			retStr = "Number of validation errors: " + rdpResp.validator.Errors.Count + ". Details are stored in IHC_ITF_ITFCOMMON_X12.RdpValidationErrors";
		}
		if (rdpResp.ackStr != null && rdpResp.ackStr.Length > 2056)
		{
    			rdpResp.ackStr = rdpResp.ackStr.Substring(0, 2056);
		}

                return new OkObjectResult(new {Transaction =transaction , FileName= fileName , Status= rdpResp.status, Details= retStr, ACK= rdpResp.ackStr });
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

                            retStr = irisObj.RdpErrorsToIris(nameSpace, rdpResp.validator, fileName, (sessionId == null) ? "" : sessionId, rdpResp.ackStr);
							

                        }
                        return new OkObjectResult(new { Transaction = transaction, FileName = fileName, Status = rdpResp.status, Details = retStr, ACK = rdpResp.ackStr });

                    }
                    else
                    {
                        return new OkObjectResult(new { Transaction = transaction, ID = X12Id, Status =  "FAIL, ID not found in IRIS" });
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
