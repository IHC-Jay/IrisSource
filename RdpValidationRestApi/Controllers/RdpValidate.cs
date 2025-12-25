using Microsoft.AspNetCore.Mvc;
using Microsoft.Win32;
using RDPCrystalEDILibrary;
using RDPCrystalEDILibrary.Rules;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Net.NetworkInformation;
using System.Text;

namespace RdpValidationRestApi.Controllers
{
    internal class RdpValidate
    {
        public X12Response ProcessX12(string x12Id, string inpFile, string transaction)
        {
            int errNum = 0;
            // Display all errors
            errNum++;

            string x12Direc = "C:\\temp\\" + transaction + "\\";
            string rulesDirec = "C:\\temp\\ihcRdpRules\\";
           

            try
            {
                string prodKey = getLicense();
                PackageLicense.Key = prodKey;

                string ruleFile = "";


                foreach (var con in X12Transactions.TransactionsArr)
                {
                    if (transaction == con.Name)
                    {
                        transaction = con.Name;
                        if (con.Rule != null)
                        {
                            ruleFile = con.Rule;
                        }
                        
                        break;
                    }
                }

                string dataFile = "";

                if (inpFile == null || inpFile == "")
                {

                    return new X12Response
                    {
                        dataFile = "File is null"
                    };
                }
                else { 
                    if (inpFile.Contains('/'))
                    {
                        dataFile = inpFile;
                    }
                    else
                    {
                        dataFile = Path.Combine(x12Direc, inpFile);
                    }
                }
                
                Console.WriteLine("Do RDP validation for " + dataFile);

                Console.WriteLine("Create EDIValidator: " + prodKey);

                EDIValidator validator = new EDIValidator();

                Console.WriteLine("Using " + rulesDirec + ruleFile + " for " + transaction +", X12 Id: " + x12Id);

                validator.EDIRulesFile = rulesDirec + ruleFile;

                // Register for the appropriate event on the EDIValidator

                validator.OnCodeCondition += new EDIValidator.CodeConditionEvent(ediValidator_CustomCondition);



                validator.EDIFile = dataFile;
                validator.Validate();

                if (validator.Passed)
                {
                    string edi997Data = CreateAck(validator);
                    var response = new X12Response
                    {
                        dataFile = $"{dataFile}!",
                        validator = validator,
                        ediRulesFile = $"{validator.EDIRulesFile}",
                        ackStr = $"{edi997Data}",
                        status = "PASS"
                    };

                    
                    return response;

                }
                else
                {
                    EDIFileParser parser = new EDIFileParser(dataFile);
                    parser.AutoDetectDelimiters = true;

                    // Start loading the file 
                    parser.BeginFileLoad();
                    Console.WriteLine("Total # of errors: " + validator.Errors.Count);
                    Span<RDPCrystalEDILibrary.EDIError> deleteErrors = new RDPCrystalEDILibrary.EDIError[50];
                    int validationInd = 0;

                    List<string> errors = new List<string>();

                    foreach (EDIError error in validator.Errors)
                    {
                        if (error.SnipLevel.ToString() == "Balance")
                        {
                            deleteErrors[validationInd++] = error;
                        }
                                            

                    }

                    foreach (RDPCrystalEDILibrary.EDIError delInd in deleteErrors)
                    {
                        if (delInd != null)
                        {
                            // Console.WriteLine("Delete error: " + delInd);
                            validator.Errors.Remove(delInd);
                        }
                    }
                    Console.WriteLine("# of errors after deleting SnipLevel: Balance: " + validator.Errors.Count);

                    foreach (EDIError error in validator.Errors)
                    {
                        Console.WriteLine(" Error Line # " + error.LineNumber.ToString() + ", SNIP: " + error.SnipLevel + ", Loop: " + error.Loop + ", Segment, Element: " + error.Segment + ", " + error.ElementOrdinal + ", Error: " + error.Message.ToString() + ", " + error.Description);

                    }

                    foreach (EDIError error in validator.Warnings)
                    {
                        Console.WriteLine(" Warning Line # " + error.LineNumber.ToString() + ", SNIP: " + error.SnipLevel + ", Loop: " + error.Loop + ", Segment, Element: " + error.Segment + ", " + error.ElementOrdinal + ", Error: " + error.Message.ToString() + ", " + error.Description);
                       
                    }
                    

                    string edi997Data = CreateAck(validator);

                    var response = new X12Response
                    {
                        dataFile = $"{dataFile}!",
                        validator = validator,
                        ackStr = $"{edi997Data}",
                        status = (validator.Errors.Count == 0) ? "PASS":"FAIL",
                        ediRulesFile = $"{validator.EDIRulesFile}"

                    };

                    return response;
                }

            }
            catch (Exception ex)
            {
                string msg = ex.Message;
                var response = new X12Response
                {
                    dataFile = $"{inpFile}!",
                    validator = null,
                    ackStr = msg,
                    status = "FAIL",
                    ediRulesFile = "Invalid request"

                };

                return response;

            }

        }

        private string getLicense()
        {

            string filePath = "C:\\temp\\RDPLicense.txt";
            string licenseKey = "C0210e1f-7f40-4629-bdd5-a531f78222ec";

            try
            {

                FileStream fileStream = new FileStream(filePath, FileMode.Open);
                using (StreamReader reader = new StreamReader(fileStream))
                {
                    licenseKey = reader.ReadToEnd();
                    // Console.WriteLine("License from: " + filePath + ": " + licenseKey);
                }


            }
            catch (IOException e)
            {
                Console.WriteLine($"The License file could not be read: {e.Message}");
            }

            return licenseKey;

        }

        private string CreateAck(EDIValidator validator)
        {
            // Create the 997 generator
            Ack999Generator ack = new Ack999Generator();

            // This char will be used to pad data to meet minimum length.  For example group control numbers
            ack.PaddingChar = '0';

            // Generate the 997 document
            EDIDocument doc997 = ack.Generate(validator);

            // Get the text
            string edi997Data = doc997.GenerateEDIData();

            // Console.WriteLine("ACK generated: " + edi997Data);
            return edi997Data;
        }


        // Write a custom validation check using .Net

        private void ediValidator_CustomCondition(object sender, CodeConditionEventArgs e)
        {
            // Console.WriteLine("In RDP custom .Net rule: " + e.CodeCondition.ToString());
            if (e.CodeCondition.Id == "shouldStartWithNumber")
            {
                /*
                Console.WriteLine(e.CurrentSegment.ToString() + ", Data count: " + e.CurrentSegment.Elements.Count);
                foreach (LightWeightElement ele in e.CurrentSegment.Elements)
                {
                    Console.WriteLine(ele.ToString() + ": " + ele.DataValue + ", " + ele.DataValue);
                }
                */
                try { 
                    var expr = @"^\d.+$";
                    bool val = System.Text.RegularExpressions.Regex.IsMatch(e.CurrentSegment.Elements[0].DataValue.ToString(), expr);
                    
                    if (val)
                    {
                        e.ConditionValid = false;                        
                    }
                    else
                    {
                        Console.WriteLine("ConditionValid Regex.IsMatch: " + e.CurrentSegment.Elements[1].DataValue + ", " + expr + ": " + val);

                        e.ConditionValid = true;
                    }
                }
                catch (IOException ex)
                {
                    Console.WriteLine($"Exception Regular Exp: {ex.Message}");
                }
            }
        }
    }

}
