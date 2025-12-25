using InterSystems.Data.IRISClient;
using Microsoft.AspNetCore.Mvc;
using RDPCrystalEDILibrary;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Dynamic;
using System.IO;
using System.IO.Pipelines;
using System.Xml.Linq;


namespace RdpValidationRestApi.Controllers
{
    [ApiController]
    [Route("X12")]
    
    public class X12Controller : ControllerBase
    {

       

        [HttpGet]
        public IActionResult Get([FromQuery] string name, [FromQuery] string? file, [FromQuery] string? transaction)
            
        {
            var irisObj = new IrisDb();
            string retStr = "";
            if (name == "Validate" && transaction != null)
            {
                if (file != null && file != "")
                {

                    Console.WriteLine("Process IRIS X12 data from file: " + irisObj.ToString());
                    var x12Data = irisObj.GetX12Data(file, transaction);
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
                        X12Response rdpResp = obj.ProcessX12(file, x12Data, transaction);

                        if (rdpResp.validator != null)
                        {

                            retStr = irisObj.RdpErrorsToIris(rdpResp.validator, file);

                        }
                        return new OkObjectResult(new { Results = $"Transaction {transaction}, ID: {file} -> {rdpResp.status}, Details: {retStr}, ACK: {rdpResp.ackStr}" });
                    }
                    else
                    {
                        return new OkObjectResult(new { Results = $"Transaction {transaction} ID: {file} not found in IRIS" });
                    }
                }
                else
                {

                    Console.WriteLine("Process X12 data from Table");
                    var outStr = irisObj.ProcessX12Table(transaction);
                    return new OkObjectResult(new { Results = $"{outStr} files processed of transaction type: {transaction}" });
                }
            }
            else if (name == "RDP" && file != null && transaction != null)
            {
               
                Console.WriteLine("X12 data file: " + file);
                var obj = new RdpValidate();
                X12Response rdpResp = obj.ProcessX12(file, file, transaction);
                if (rdpResp.validator != null)
                {

                    retStr = irisObj.RdpErrorsToIris(rdpResp.validator, file);

                }
                return new OkObjectResult(new { Results = $"Transaction {transaction} {file} -> {rdpResp.status}, Details: {retStr}, ACK: {rdpResp.ackStr}" });
            }
            
            
            else if (name == "IRIS" && file != null && transaction != null)
            {

                var outStr = irisObj.GetX12Data(file, transaction);

                return new OkObjectResult(new { Results = $"{transaction} X12 date, ID: {file} is stored in {outStr}" });

            }

            else if (name != "")
            {
                Console.WriteLine("Hello " + name +", " + file);
                var response = new X12Response
                {

                    dataFile = $"Hello, {name}!",
                    ackStr = $"{file}",
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
