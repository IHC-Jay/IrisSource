Class IHC.EAI.KPI.Operation.Metrics Extends EnsLib.REST.Operation
{

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method OnMessage(pRequest As %Library.Persistent, Output pResponse As %Library.Persistent) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		If (pRequest.%IsA("IHC.EAI.KPI.Message.Request")) {
			Set tStatus = ..SendRequest(pRequest,.pResponse)
			$$$ThrowOnError(tStatus)
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrRequestNotHandled, pRequest.%ClassName(1)))
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()	
	}
	Quit tStatus
}

/// Send the request
Method SendRequest(pRequest As IHC.EAI.KPI.Message.Request, Output pResponse As IHC.EAI.KPI.Message.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tCommand = $ZCONVERT(pRequest.Command,"U")
		
		If (tCommand = "PUT") {
			Set tStatus = ..SendPutRequest(pRequest,.pResponse)
			$$$ThrowOnError(tStatus)
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrRequestNotHandled, "API does not currently support this command: " _ pRequest.Command _ "|Name: " _ pRequest.Name))		
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Send the request
Method SendPutRequest(pRequest As IHC.EAI.KPI.Message.Request, Output pResponse As IHC.EAI.KPI.Message.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set pResponse = ##class(IHC.EAI.KPI.Message.Response).%New()
		
		Set tURL = ..Adapter.URL
		Set:(pRequest.URL '= "") tURL = pRequest.URL
		Set tStatus = ..Adapter.PutURL(tURL,.tHttpResponse,"",pRequest.JSONStream)
		
		If ($$$ISERR(tStatus) && $IsObject(tHttpResponse) && $IsObject(tHttpResponse.Data) && tHttpResponse.Data.Size) {
			Set tStatus = $$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(tStatus)_":"_tHttpResponse.Data.Read())
			$$$ThrowOnError(tStatus)
		}
		
		If ($$$IsdefObject(tHttpResponse)) {
			Do tHttpResponse.Data.Rewind()
			Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
			Do pResponse.JSONStream.CopyFrom(tHttpResponse.Data)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	Set tStatus = $$$OK
	
	Try {
		
		// Determine how to configure the http endpoint
		Set tServerHost = $GET(^EAI.Setting("ServerNodeHost"),"")
		Set tServerPort = $GET(^EAI.Setting("ServerNodePort"),"")
		
		Set:(tServerHost '= "") ..Adapter.HTTPServer = tServerHost
		Set:(tServerPort '= "") ..Adapter.HTTPPort = tServerPort
		
		Set tCredObj = ##class(Ens.Config.Credentials).%OpenId("ITF_Services")
		
		Set:($$$IsdefObject(tCredObj)) ..Adapter.Credentials = "ITF_Services"
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	
	Quit tStatus
}

}