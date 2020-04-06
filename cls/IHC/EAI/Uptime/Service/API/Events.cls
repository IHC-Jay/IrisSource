/// REST service API
Class IHC.EAI.Uptime.Service.API.Events Extends EnsLib.REST.Service
{

Parameter ADAPTER;

Parameter EnsServicePrefix = "|";

XData UrlMap
{
<Routes>
<Route Url="/events/" Method="GET" Call="GetDownEvents"/>
<Route Url="/events/configdown/" Method="PUT" Call="CreateDownEvents"/>
<Route Url="/healthcheck/" Method="GET" Call="HealthCheck"/>
</Routes>
}

/// This method creates down event records<br/>
/// Return...anything?<br/>
Method CreateDownEvents(
	pInput As %Library.AbstractStream,
	Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	
	Do pOutput.SetAttribute("Content-Type","application/json")
		
	Try {
		
		Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(pInput)
			
		Set tIter = tConsumedJSON.%GetIterator()
		
		Set tRecordedCount = 0
		While (tIter.%GetNext(.key,.value)) {
		
			Set tConfigName = value.ConfigName
			Set tNamespace = value.Namespace
			Set tBusinessType = value.BusinessType
			Set tStart = value.DownStart
			Set tEnd = value.DownEnd
			Set tReason = value.Reason
		
			Set tDownEvent = ##class(IHC.EAI.Uptime.Data.ConfigDownEvent).%New()
			Set tDownEvent.ConfigName = tConfigName
			Set tDownEvent.Namespace = tNamespace
			Set tDownEvent.BusinessType = tBusinessType
			Set tDownEvent.DownStart = tStart
			Set tDownEvent.DownEnd = tEnd
			Set tDownEvent.Reason = tReason
			
			Set tStatus = tDownEvent.%Save()
			$$$ThrowOnError(tStatus)
			Set tRecordedCount = tRecordedCount + 1
		}
		
		Do pOutput.Write("{""success"": true,""message"":""" _ tRecordedCount _ " events successfully recorded""}"_$C(13,10))

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
  		Do pOutput.Write("""name"": ""Ensemble Uptime"",")
  		Do pOutput.Write("""message"": ""Service is running"",")
  		Do pOutput.Write("""success"": true")
		Do pOutput.Write("}")
 		
 		
 		do pOutput.Write("}"_$C(13,10))
 		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

/// This method provides a GET service for down events <br/>
ClassMethod GetDownEvents(
	pInput As %Library.AbstractStream,
	Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try { 
 		// You could just write the output manually or use helper methods like ..ObjectToJSONStream() to generate JSON
 		Do pOutput.SetAttribute("Content-Type","application/json")
 		
		Do pOutput.Write("{""message"": ""Not currently implemented. Check back later.""}"_$C(13,10))
 		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

}