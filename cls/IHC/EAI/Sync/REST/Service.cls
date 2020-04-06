Class IHC.EAI.Sync.REST.Service Extends EnsLib.REST.Service
{

Parameter ADAPTER;

Parameter EnsServicePrefix = "|sync";

XData UrlMap
{
<Routes>
<Route Url="/ssl" Method="PUT" Call="SyncSSL"/>
<Route Url="/tasks" Method="PUT" Call="SyncTasks"/>
<Route Url="/hl7schemas" Method="PUT" Call="SyncHL7Schemas"/>
<Route Url="/sqlgateway" Method="PUT" Call="SyncSQLGateway"/>
<Route Url="/healthcheck" Method="GET" Call="HealthCheck"/>
</Routes>
}

/// This method deploys a single action
Method SyncSSL(
	pInput As %Library.AbstractStream,
	Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK, tConsumedJSON = ""
	
	Do pOutput.SetAttribute("Content-Type","application/json")
		
	Try {
		
		// Only perform this action on a backup mirror member
		If (($System.Mirror.IsMember()) && ('$System.Mirror.IsPrimary())) {
			
			// Clear existing entries
			Set tStatus = ##class(IHC.EAI.Sync.Util).DeleteSSLConfigs()
			$$$ThrowOnError(tStatus)
			
			Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(pInput)
				
			Set tIter = tConsumedJSON.%GetIterator()
			
			Set tRecordCount = 0
			While (tIter.%GetNext(.tKey,.tRecord)) {
				
				Set tProperties("CAFile") = tRecord.CAFile
				Set tProperties("CAPath") = tRecord.CAPath
				Set tProperties("CRLFile") = tRecord.CRLFile
				Set tProperties("CertificateFile") = tRecord.CertificateFile
				Set tProperties("CipherList") = tRecord.CipherList
				Set tProperties("Description") = tRecord.Description
				Set tProperties("Enabled") = tRecord.Enabled
				Set tProperties("PrivateKeyFile") = tRecord.PrivateKeyFile
				Set tProperties("PrivateKeyPassword") = tRecord.PrivateKeyPassword
				Set tProperties("PrivateKeyType") = tRecord.PrivateKeyType
				Set tProperties("Protocols") = tRecord.Protocols
				Set tProperties("Type") = tRecord.Type
				Set tProperties("VerifyDepth") = tRecord.VerifyDepth
				Set tProperties("VerifyPeer") = tRecord.VerifyPeer
				
				Set tStatus = ##class(IHC.EAI.Sync.Util).CreateSSLConfig(tRecord.Name,tProperties)
				
				Set tRecordCount = tRecordCount + 1
			}
			
			Do pOutput.Write("{""success"": true,""message"":""" _ tRecordCount _" records successfully created.""}"_$C(13,10))
			
		} Else {
			Do pOutput.Write("{""success"": false,""message"":""Instance is not a backup mirror member.""}"_$C(13,10))
			Quit
		}
		
		Do pOutput.Write("{""success"": true,""message"":""Nothing deployed, and no errors were record. Possible issue with POST data.""}"_$C(13,10))

	} Catch (eException) {
		Set tStatus = eException.AsStatus()
		Set tErrorMessage = $System.Status.GetErrorText(tStatus)
		Do pOutput.Write("{""success"": false,""message"":""" _ tErrorMessage _ """}"_$C(13,10))
	}
	
    Quit tStatus
}


/// This method provides a service health check for consumers <br/>
/// Return a json array stating the system is up and running
ClassMethod HealthCheck(
	pInput As %Library.AbstractStream,
	Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try { 
 		// You could just write the output manually or use helper methods like ..ObjectToJSONStream() to generate JSON
 		Do pOutput.SetAttribute("Content-Type","application/json")
 		Do pOutput.Write("{")
 		

		Do pOutput.Write("""app"": {")
  		Do pOutput.Write("""name"": ""EAI Sync Service"",")
  		Do pOutput.Write("""message"": ""Service is running"",")
  		Do pOutput.Write("""success"": true")
		Do pOutput.Write("}")
 		
 		
 		do pOutput.Write("}"_$C(13,10))
 		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

}