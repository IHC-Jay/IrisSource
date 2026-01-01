using InterSystems.Data.IRISClient;
using Microsoft.AspNetCore.Mvc;
using RDPCrystalEDILibrary;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics;
using System.Reflection.PortableExecutable;
using System.Text;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace RdpValidationRestApi.Controllers
{
    internal class IrisDb
    {
        public int ProcessX12Table(string transaction, string filePath)
        {

            string x12Id = "";
            string x12Data = "";
            string flNm = "";
            int numFiles = 0;

            IRISConnection IRISConnect = ConnectToIRIS();

            string queryString = "SELECT ID, FileName, x12Data, SessionID FROM IHC_X12.Data" + transaction + " where X12DataParentId is null and x12Data like 'ISA%'";
            Console.WriteLine("SQL: " + queryString);

            IRISCommand irisCmd = new IRISCommand(queryString, IRISConnect);
            IRISDataReader reader = irisCmd.ExecuteReader();

            Console.WriteLine("Printing out contents of SELECT query: " + reader.HasRows);
            while (reader.Read())
            {
                x12Id = reader.GetValue(0).ToString();
                x12Data = reader.GetValue(2).ToString();
                string sessionId = reader.GetValue(3).ToString();

                flNm = reader.GetValue(1).ToString();
                flNm = filePath + "/" + transaction + "/" + System.IO.Path.GetFileName(flNm);

                Console.WriteLine($"SQL output, ID: " + x12Id +", Filename: " + flNm +", X12 size: " + x12Data.Length);

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

                X12ToFile(x12Data, transaction, flNm);
                numFiles++;
                // Validate X12

                var obj = new RdpValidate();
                X12Response rdpResp = obj.ProcessX12(flNm, transaction, filePath);

                if (rdpResp.validator != null)
                {

                    string retStr = RdpErrorsToIris(rdpResp.validator, x12Id, sessionId);
                    Console.WriteLine(retStr);

                }

            }

            reader.Close();

            irisCmd.Dispose();
            IRISConnect.Close();

            return numFiles;
        }

        public string GetX12Data(string x12Id, string transaction, string filePath)
        {
            string x12Data = "";
            string flNm = "";

            IRISConnection IRISConnect = ConnectToIRIS();

            string queryString = "SELECT ID, FileName, x12Data FROM IHC_X12.Data" + transaction + " where ID = " + x12Id;
            Console.WriteLine("SQL: " + queryString);

            IRISCommand irisCmd = new IRISCommand(queryString, IRISConnect);
            IRISDataReader reader = irisCmd.ExecuteReader();

            Console.WriteLine("SELECT query HasRows: " + reader.HasRows);
            if (reader.Read())
            {
                
                x12Data = reader.GetValue(2).ToString();
                flNm = reader.GetValue(1).ToString();
                flNm = filePath + System.IO.Path.GetFileName(flNm);

                Console.WriteLine($"SQL output, Filename: " + flNm + ", X12 size: " + x12Data.Length);

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
                X12ToFile(x12Data, transaction,  flNm);
            }

            reader.Close();

            irisCmd.Dispose();
            IRISConnect.Close();

            return flNm;

        }
      
        public string RdpErrorsToIris(EDIValidator validator, string x12Id, string SessionId)
        {
           
            string validationStr = "";

            try
            {

                if (validator.Errors.Count <= 0)
                {
                    validationStr = "Validation Passed " + validator.Passed + ". No errors in X12 validation" ;
                }
                else
                { 


                    IRISConnection IRISConnect = ConnectToIRIS();

                    string queryString = "INSERT INTO IHC_ITF_ITFCOMMON_X12.RdpValidationErrors(LineNum,TransactionSet,SegmentData,FieldValue,SnipLevel,Loop,Segment,Element,ErrorCode,ErrorDesc,ErrorType,X12DataId,TransactionType,ProcessDtTm, SessionId) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                    Console.WriteLine("SQL: " + queryString);

                    foreach (EDIError error in validator.Errors)
                    {
                        IRISCommand irisCmd = new IRISCommand(queryString, IRISConnect);
                        IRISParameter param1 = new IRISParameter("LineNum", IRISDbType.Int);
                        param1.Value = error.LineNumber;
                        IRISParameter param2 = new IRISParameter("TransactionSet", IRISDbType.NVarChar);
                        param2.Value = error.STSegment.ToString();
                        IRISParameter param3 = new IRISParameter("SegmentData", IRISDbType.NVarChar);
                        param3.Value = error.ValidatingSegment.ToString();

                        IRISParameter param4 = new IRISParameter("FieldValue", IRISDbType.NVarChar);
                        string fv = "";

                        Console.WriteLine("Element: " + error.ValidatingSegment.Elements.Count + " >= " + error.ElementOrdinal);

                        if (error.ValidatingSegment.Elements.Count >= error.ElementOrdinal && error.ElementOrdinal > 0 &&
                            error.ValidatingSegment.Elements.ElementAt(error.ElementOrdinal - 1) != null)
                        {
                            LightWeightElement ele = error.ValidatingSegment.Elements.ElementAt(error.ElementOrdinal - 1);
                            // Console.WriteLine(" -- " + error.ElementOrdinal + ": " + ele.Composite + ", " + ele.Elements.Count);
                            if (ele.Composite)
                            {
                                fv = string.Join(":", ele.Elements);
                            }
                            else
                            {
                                fv = ele.ToString();
                            }
                        }
                        if (fv == "")
                        {
                            fv = "<EMPTY>";
                        }

                        param4.Value = fv;

                        IRISParameter param5 = new IRISParameter("SnipLevel", IRISDbType.NVarChar);
                        param5.Value = error.SnipLevel.ToString();
                        IRISParameter param6 = new IRISParameter("Loop", IRISDbType.NVarChar);
                        param6.Value = error.Loop;
                        IRISParameter param7 = new IRISParameter("Segment", IRISDbType.NVarChar);
                        param7.Value = error.Segment;
                        IRISParameter param8 = new IRISParameter("Element", IRISDbType.NVarChar);
                        param8.Value = error.ElementOrdinal.ToString();
                        IRISParameter param9 = new IRISParameter("ErrorCode", IRISDbType.NVarChar);
                        param9.Value = error.Message.ToString();
                        IRISParameter param10 = new IRISParameter("ErrorDesc", IRISDbType.NVarChar);
                        param10.Value = error.Description;
                        IRISParameter param11 = new IRISParameter("ErrorType", IRISDbType.NVarChar);
                        param11.Value = "Error";
                        IRISParameter param12 = new IRISParameter("X12DataId", IRISDbType.NVarChar);
                        param12.Value = x12Id;
                        IRISParameter param13 = new IRISParameter("TransactionType", IRISDbType.NVarChar);
                        param13.Value = error.STSegment.Elements.ElementAt(0).ToString();

                        IRISParameter param14 = new IRISParameter("ProcessDtTm", IRISDbType.DateTime);
                        param14.Value = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

                        IRISParameter param15 = new IRISParameter("SessionId", IRISDbType.NVarChar);
                        param15.Value = SessionId;

                        irisCmd.Parameters.Add(param1);
                        irisCmd.Parameters.Add(param2);
                        irisCmd.Parameters.Add(param3);
                        irisCmd.Parameters.Add(param4);
                        irisCmd.Parameters.Add(param5);
                        irisCmd.Parameters.Add(param6);
                        irisCmd.Parameters.Add(param7);
                        irisCmd.Parameters.Add(param8);
                        irisCmd.Parameters.Add(param9);
                        irisCmd.Parameters.Add(param10);
                        irisCmd.Parameters.Add(param11);
                        irisCmd.Parameters.Add(param12);
                        irisCmd.Parameters.Add(param13);
                        irisCmd.Parameters.Add(param14);
                        irisCmd.Parameters.Add(param15);

                        validationStr += param1.Value + ", " + param2.Value + ", " + param3.Value +
                            ", " + param4.Value + ", " + param5.Value + ", " + param6.Value +
                            ", " + param7.Value + ", " + param8.Value + ", " + param9.Value
                            + ", " + param10.Value + ", " + param11.Value + ", " + param12.Value + ", " 
                            + param13.Value + ", " + param14.Value + ", " + param15.Value + ";";

                        int rows = irisCmd.ExecuteNonQuery();

                        Console.WriteLine("Added " + rows + " row for " + validationStr);
                        irisCmd.Dispose();
                    }

                    IRISConnect.Close();
                }
            }
            catch (Exception eInsert)
            {
                Console.WriteLine("Exception: " + eInsert.ToString());
            }
            
            
            return validationStr;
        }

        public IRISConnection ConnectToIRIS()
        {
            string host = "lp-itfdevvp2";
            string port = "6973";
            string username = "rdpuser";
            string password = "crystal123";
            string Namespace = "EDIPAYER";

            IRISConnection IRISConnect = new IRISConnection();
            Console.WriteLine("connect to IRIS " + host + ":" + port +", User: " + username);

            IRISConnect.ConnectionString = "Server = " + host
                + "; Port = " + port + "; Namespace = " + Namespace
                + "; Password = " + password + "; User ID = " + username;

            IRISConnect.Open();
            Console.WriteLine("Connected to IRIS  " + host + ":" + port +", " + IRISConnect.Database +", User: " + username);
            return IRISConnect;
        }

        private void X12ToFile(string X12Data, string transation, string filePath)
        {

            try
            {
                using (StreamWriter wr = new StreamWriter(filePath))
                {
                    wr.Write(X12Data);
                    Console.WriteLine("X12 data saved in: " + filePath);
                }


            }
            catch (IOException e)
            {
                Console.WriteLine($"The file could not be created: {e.Message}");
            }

        }

    }

}
