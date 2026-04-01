using Microsoft.AspNetCore.Mvc;
using Microsoft.Win32;
using RDPCrystalEDILibrary;
using RDPCrystalEDILibrary.Rules;
using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Net.NetworkInformation;
using System.Text;

namespace RdpValidationRestApi.Controllers
{
    internal class RdpValidate
    {
        public X12Response ProcessX12(string dataFile, string transaction, string rulesPath, string ruleFile, int snipLevel, string ignoreSegments)
        {
            int errNum = 0;
	    const int MAX_ERRORS  = 999;
            // Display all errors
            errNum++;
	    Console.WriteLine("In ProcessX12, file:" + dataFile);


            if (!System.IO.File.Exists(dataFile))
            {
		Console.WriteLine("File do not Exists: " +dataFile);
                var response = new X12Response
                {
                    dataFile = $"{dataFile}!",
                    validator = null,
                    ackStr = "Data file does not exists:" + dataFile,
                    status = "FAIL",
                    ediRulesFile = "NA"

                };

                return response;

            }

            try
            {
		string[] segments = null;
		    if(ignoreSegments != null)
		    {
			segments = ignoreSegments.Split(",");
		    }
                string prodKey = getLicense();
                PackageLicense.Key = prodKey;

                if (ruleFile == null || ruleFile == "")
                { 

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
                }
            
                
                Console.WriteLine("Do RDP validation for " + dataFile);

                Console.WriteLine("Create EDIValidator: " + prodKey);

                EDIValidator validator = new EDIValidator();
		validator.AutoDetectDelimiters = true;
		validator.MaxErrorsBeforeThrowingException = 5000;

                Console.WriteLine("Using " + rulesPath + ruleFile + " for " + transaction +", SNIP:" + snipLevel);

                validator.EDIRulesFile = rulesPath + ruleFile;

                // Register for the appropriate event on the EDIValidator

                validator.OnCodeCondition += new EDIValidator.CodeConditionEvent(ediValidator_CustomCondition);



                validator.EDIFile = dataFile;
		FileInfo fileInfo = new FileInfo(dataFile);
		if (fileInfo.Length > 1000000)
		{
			validator.LoadValidatedData = false;
			Console.WriteLine("LoadValidatedData property is turned off ");
		}
		else
		{
                	Console.WriteLine("Load full X12");
		}
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
                    RDPCrystalEDILibrary.SnipTestLevel snipCheck = RDPCrystalEDILibrary.SnipTestLevel.Integrity; // SNIP 1

                    EDIFileParser parser = new EDIFileParser(dataFile);
                    parser.AutoDetectDelimiters = true;

                    // Start loading the file 
                    parser.BeginFileLoad();
                    Span<RDPCrystalEDILibrary.EDIError> deleteErrors = new RDPCrystalEDILibrary.EDIError[MAX_ERRORS];
                    int validationInd = 0;

                    List<string> errors = new List<string>();
                    if (snipLevel == 2)
                    {
                        snipCheck = RDPCrystalEDILibrary.SnipTestLevel.Requirement;
                    }
                    else if(snipLevel == 3)
                    {
                        snipCheck = RDPCrystalEDILibrary.SnipTestLevel.Balance;
                    }
                    else if (snipLevel > 3)
                    {
                        snipCheck = RDPCrystalEDILibrary.SnipTestLevel.Situational;
                    }
                    Console.WriteLine("Total # of errors: " + validator.Errors.Count + ", snipLevel: " + snipLevel +", snipCheck: " + snipCheck);
		    if (validator.Errors.Count > MAX_ERRORS)
		    {
                	var err = new X12Response
                	{
                    	dataFile = $"{dataFile}!",
                        validator = null,
                    	ackStr = null,
                    	status = "FAIL, Aborting. More than MAX_ERRORS errors: "+  MAX_ERRORS,
                    	ediRulesFile = $"{validator.EDIRulesFile}"
	
                	};

                	return err;
		    }

                    foreach (EDIError error in validator.Errors)
                    {
			Console.WriteLine(" - Line: " + error.LineNumber.ToString() + ", SNIP: " + error.SnipLevel + ", Loop: " + error.Loop + ", Segment/Element: " + error.Segment + "/" + error.ElementOrdinal + ", Error: " + error.Message.ToString() + ", " + error.Description);
			if (validationInd >= MAX_ERRORS)
			{
				break;
			}

                        if (error.SnipLevel > snipCheck )
                        {
                            deleteErrors[validationInd++] = error;
                        }
			if (segments != null && segments.Contains(error.Segment) )
                        {
				Console.WriteLine("Ignore segment: " +  error.Segment );
                            deleteErrors[validationInd++] = error;
                        }
                                            
                                            

                    }

		    Console.WriteLine("Delete errors");
                    foreach (RDPCrystalEDILibrary.EDIError delInd in deleteErrors)
                    {
                        if (delInd != null)
                        {
                            // Console.WriteLine("Delete error: " + delInd);
                            validator.Errors.Remove(delInd);
                        }
                    }
                    Console.WriteLine("# of errors after deleting SnipLevel " + snipCheck +" = " + validator.Errors.Count);

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
                    dataFile = $"{dataFile}!",
                    validator = null,
                    ackStr = msg,
                    status = "FAIL, Exception: " + ex,
                    ediRulesFile = "NA"

                };

                return response;

            }

        }

        private string getLicense()
        {

            string filePath = "/usr/local/dotnet/RdpValidationRestApi/RDPLicense.txt";
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
            e.ConditionValid = false;
	    string fldVal = e.CurrentSegment.Elements[0].DataValue.ToString();
	    Console.WriteLine(" ---- ");
            Console.WriteLine("In RDP CustomCondition: " + e.CodeCondition.ToString() +", sender: " + sender);
	    Console.WriteLine("Data: " + fldVal +  e.CurrentLoop);
            foreach (LightWeightElement ele in e.CurrentSegment.Elements)
            {
                    Console.Write(ele.DataValue + ", ");
            }
            Console.WriteLine(" ---- Data count: " + e.CurrentSegment.Elements.Count);


	    if (e.CodeCondition.Id == "npiValidation")
		{
    		if (e.CurrentSegment.Elements[0].ToString() == "1P")
    		{
		    	string npiNum = e.CurrentSegment.Elements[8].ToString();
				
    			Console.WriteLine("NPI Data 1, 9: " + e.CurrentSegment.Elements[0] + ", " + npiNum);
        		e.ConditionValid = !Util.NpiValidator.IsValidNpi(npiNum);
        		Console.WriteLine("NPI valid:" + e.ConditionValid);
    		}
	    }
	    else if (e.CodeCondition.Id == "prvValidation")
		{
    		if (e.CurrentSegment.Elements[1].ToString() == "HPI")
    		{
		    	string npiNum = e.CurrentSegment.Elements[2].ToString();
				
    			Console.WriteLine("HPI Data 1, 3: " + e.CurrentSegment.Elements[0] + ", " + npiNum);
        		e.ConditionValid = !Util.NpiValidator.IsValidNpi(npiNum);
        		Console.WriteLine("PRV HPI NpiValidator:" + e.ConditionValid);
    		}
	    }
	    else if (e.CodeCondition.Id == "dtpValidation")
		{
		    	string dob = e.CurrentSegment.Elements[2].ToString();
				
    			Console.WriteLine("Date 1, 9: " + e.CurrentSegment.Elements[1] + ", " + dob);
        		e.ConditionValid = !Util.DtpValidator.IsValid(e.CurrentSegment.Elements[1].ToString(), dob);
        		Console.WriteLine("DTP valid:" + e.ConditionValid);
	    }
	    else if (e.CodeCondition.Id == "dobValidation")
		{
    		if (e.CurrentSegment.Elements[0].ToString() == "D8")
    		{
		    	string dob = e.CurrentSegment.Elements[1].ToString();
				
    			Console.WriteLine("Date 1, 9: " + e.CurrentSegment.Elements[0].ToString() + ", " + dob);
        		e.ConditionValid = !Util.DobValidator.IsValid(dob);
        		Console.WriteLine("DoB valid:" + e.ConditionValid);
    		}
	    }
	    else if (e.CodeCondition.Id == "refValidation")
		{
    		if (e.CurrentSegment.Elements[0].ToString() == "SY")
    		{
		    	string ssnNum = e.CurrentSegment.Elements[1].ToString();
				
    			Console.WriteLine("SSN Data 1, 2: " + e.CurrentSegment.Elements[0] + ", " + ssnNum);
        		e.ConditionValid = !Util.SsnValidator.IsValid(ssnNum);
        		Console.WriteLine("SSN valid:" + e.ConditionValid);
    		}
                if (e.CurrentSegment.Elements[0].ToString() == "EI" || e.CurrentSegment.Elements[0].ToString() == "TJ")
                {
                        string einNum = e.CurrentSegment.Elements[1].ToString();

                        Console.WriteLine("EIN Data 1, 2: " + e.CurrentSegment.Elements[0] + ", " + einNum);
                        e.ConditionValid = !Util.EinValidator.IsValid(einNum);
                        Console.WriteLine("EIN valid:" + e.ConditionValid);
                }

		else if (e.CurrentSegment.Elements[0].ToString() == "EA")
    		{
		    	string medNum = e.CurrentSegment.Elements[1].ToString();
    			Console.WriteLine("EA Data 1, 2: " + e.CurrentSegment.Elements[0] + ", " + medNum);
			string pattern = @"^[a-zA-Z0-9]+$";
    			e.ConditionValid = !System.Text.RegularExpressions.Regex.IsMatch(medNum, pattern);
        		Console.WriteLine("EA valid:" + e.ConditionValid);
    		}
	    }
	    else if ( e.CodeCondition.Id == "zipValidation")
	    {
		    	string st = e.CurrentSegment.Elements[1].ToString();
		    	string zip = e.CurrentSegment.Elements[2].ToString();
    			Console.WriteLine("ZIP Data 1, 3: " + e.CurrentSegment.Elements[0] + ", " + zip);
				try {
					string csvPath = "/usr/local/dotnet/rdp-api/Lookup/States.csv";
        				string val = Util.CsvLookup.GetSecondValueByKey(csvPath, st);
        				Console.WriteLine(st + " CSV:" + val);
					if (val == null || val == "")
					{
				   		e.ConditionValid = true;
					}
				}
                		catch (IOException ex)
                		{
                    			Console.WriteLine($"Exception Regular Exp: {ex.Message}");
				}
			if (zip.Length > 0)
			{
				string pattern = @"^\d{5}(-\d{4})?$|^(\d{5}|\d{9})$";
    				e.ConditionValid = !System.Text.RegularExpressions.Regex.IsMatch(zip, pattern);
        			Console.WriteLine("ZIP valid:" + e.ConditionValid);
			}
	    }
	    else if ( e.CodeCondition.Id == "nmValidation")
	    {
		    	string nm2 = e.CurrentSegment.Elements[2].ToString();
		    	string nm3 = e.CurrentSegment.Elements[3].ToString();
    			Console.WriteLine("Name Data 1, 3: " + e.CurrentSegment.Elements[0] + ", " + nm2 +", " + nm3);
			// [A-Za-z'-]+: Allows one or more letters, apostrophes ('), or hyphens (-).
			string pattern = @"^[A-Za-z][A-Za-z'-]+([ A-Za-z][A-Za-z'-]+)*$";
			if (nm2.Length > 0)
			{
    				e.ConditionValid = !System.Text.RegularExpressions.Regex.IsMatch(nm2, pattern);
        			Console.WriteLine("NM 2 valid:" + e.ConditionValid);
			}
			if (nm3.Length > 0 && e.ConditionValid == false)
			{
    				e.ConditionValid = !System.Text.RegularExpressions.Regex.IsMatch(nm3, pattern);
        			Console.WriteLine("NM 3 valid:" + e.ConditionValid);
			}
	    }
	    if (e.CodeCondition.Id == "eqLookup" && e.CurrentSegment.Elements.Count > 1)
		{
		    	string eq2 = e.CurrentSegment.Elements[2].ToString();
				
    			Console.WriteLine("EQ Data 1, 9: " + e.CurrentSegment.Elements[0] + ", " + eq2);
			if (eq2 != null && eq2.Length > 0)
                        {
				try {
					string csvPath = "/usr/local/dotnet/rdp-api/Lookup/EQ-02.csv";
        				string val = Util.CsvLookup.GetSecondValueByKey(csvPath, eq2);
        				Console.WriteLine("CSV:" + val);
					if (val == null || val == "")
					{
				   		e.ConditionValid = true;
					}
				}
                		catch (IOException ex)
                		{
                    			Console.WriteLine($"Exception Regular Exp: {ex.Message}");
                		}
			}
	    }

	    else if (e.CodeCondition.Id == "shouldStartWithNumber")
            {
                
                
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

                    }
                }
                catch (IOException ex)
                {
                    Console.WriteLine($"Exception Regular Exp: {ex.Message}");
                }
            }
	    Console.WriteLine(" **** " + e.CodeCondition.Id + "= " +  (e.ConditionValid? "FAIL" : "PASS") + " ---- ");
        }
    }

}
