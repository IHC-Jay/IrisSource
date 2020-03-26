/// REST service API for ITF Metrics
Class IHC.EAI.KPI.Service.API.Metrics Extends EnsLib.REST.Service
{

Parameter ADAPTER;

Parameter EnsServicePrefix = "|";

Parameter SETTINGS = "MetricsProcess";

Property MetricsProcess As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.KPI.Process.API.Metrics" ];

XData UrlMap
{
<Routes>
<Route Url="/count/transaction/" Method="PUT" Call="CreateTransactionCount"/>
<Route Url="/count/component/" Method="PUT" Call="CreateComponentCount"/>
<Route Url="/healthCheck/" Method="GET" Call="HealthCheck"/>
</Routes>
}

/// This method creates a transaction count record<br/>
/// Return a json representation of persistent obj<br/>
Method CreateTransactionCount(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tRequest = ##class(IHC.EAI.KPI.Message.API.Request).%New()
		Set tRequest.Name = "TransactionCount"
		Set tRequest.JSONStream = pInput
		
		Set tResponse = ""
		Set tStatus = ..SendRequestSync(..MetricsProcess,tRequest,.tResponse)
		$$$ThrowOnError(tStatus)
		
		If (($$$IsdefObject(tResponse)) && (tResponse.%IsA("IHC.EAI.KPI.Message.API.Response"))) {
			Do pOutput.SetAttribute("Content-Type","application/json")
			
			Set tStatus = ..ObjectToJSONStream(tResponse,.tResponseStream,"aciwu")
 			$$$ThrowOnError(tStatus)
 			
 			Set tStatus = pOutput.CopyFrom(tResponseStream)
 			$$$ThrowOnError(tStatus)
		}
		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

/// This method creates a component count record<br/>
/// Return a json representation of persistent obj<br/>
Method CreateComponentCount(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tRequest = ##class(IHC.EAI.KPI.Message.API.Request).%New()
		Set tRequest.Name = "ComponentCount"
		Set tRequest.JSONStream = pInput
		
		Set tResponse = ""
		Set tStatus = ..SendRequestSync(..MetricsProcess,tRequest,.tResponse)
		$$$ThrowOnError(tStatus)
		
		If (($$$IsdefObject(tResponse)) && (tResponse.%IsA("IHC.EAI.KPI.Message.API.Response"))) {
			Do pOutput.SetAttribute("Content-Type","application/json")
 			
 			Set tStatus = ..ObjectToJSONStream(tResponse,.tResponseStream,"aciwu")
 			$$$ThrowOnError(tStatus)
 			
 			Set tStatus = pOutput.CopyFrom(tResponseStream)
 			$$$ThrowOnError(tStatus)
		}
		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

/// This method provides a service health check for consumers <br/>
/// Return a json array stating the system is up and running
ClassMethod HealthCheck(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try { 
 		// You could just write the output manually or use helper methods like ..ObjectToJSONStream() to generate JSON
 		Do pOutput.SetAttribute("Content-Type","application/json")
 		Do pOutput.Write("{")
 		

		Do pOutput.Write("""app"": {")
  		Do pOutput.Write("""name"": ""ITF Metrics"",")
  		Do pOutput.Write("""message"": ""Application is running"",")
  		Do pOutput.Write("""success"": true")
		Do pOutput.Write("}")
 		
 		
#; 		Set tOut=##class(%IO.StringStream).%New()
#; 		do ..ObjectToJSONStream(tProxy,.tOut)	
#; 		
#; 		do tOut.Rewind()
#; 		do pOutput.Write( tOut.Read() )
 		do pOutput.Write("}"_$C(13,10))
 		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

}
