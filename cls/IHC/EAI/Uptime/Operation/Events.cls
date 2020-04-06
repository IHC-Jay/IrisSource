Class IHC.EAI.Uptime.Operation.Events Extends EnsLib.REST.Operation
{

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method OnMessage(
	pRequest As %Library.Persistent,
	Output pResponse As %Library.Persistent) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		If (pRequest.%IsA("IHC.EAI.Uptime.Message.Request")) {
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
Method SendRequest(
	pRequest As IHC.EAI.Uptime.Message.Request,
	Output pResponse As IHC.EAI.Uptime.Message.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tCommand = $ZCONVERT(pRequest.Command,"U")
		
		If (tCommand = "GET") {
			Set tStatus = ..SendGETRequest(pRequest,.pResponse)
			$$$ThrowOnError(tStatus)
		} ElseIf (tCommand = "PUT") {
			Set tStatus = ..SendPUTRequest(pRequest,.pResponse)
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
Method SendGETRequest(
	pRequest As IHC.EAI.Uptime.Message.Request,
	Output pResponse As IHC.EAI.Uptime.Message.Response) As %Status
{
	Set tStatus = $$$OK, tHttpResponse = ""
	Try {
		Set pResponse = ##class(IHC.EAI.Uptime.Message.Response).%New()
	
		Set:(pRequest.Server '= "") ..Adapter.HTTPServer = pRequest.Server
		Set:(pRequest.Port '= "") ..Adapter.HTTPPort = pRequest.Port
		
		Set tURL = ..Adapter.URL
		Set:(pRequest.URL '= "") tURL = pRequest.URL
		Set tStatus = ..Adapter.GetURL(tURL,.tHttpResponse,"",pRequest.JSONStream)
		$$$ThrowOnError(tStatus)
		
		If ($IsObject(tHttpResponse) && $IsObject(tHttpResponse.Data) && tHttpResponse.Data.Size) {
			Do tHttpResponse.Data.Rewind()
			Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
			Do pResponse.JSONStream.CopyFrom(tHttpResponse.Data)
		} Else {
			Set tErrorResponseStream = ..CreateJSONErrorResponse("Empty/Null response object.",.tStatus)
			$$$ThrowOnError(tStatus)
			Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
			Do pResponse.JSONStream.CopyFrom(tErrorResponseStream)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
		
		Set tErrorMessage = ""
		If ($IsObject(tHttpResponse) && $IsObject(tHttpResponse.Data) && tHttpResponse.Data.Size) {
			Set tErrorMessage = $$$StatusDisplayString(tStatus)_":"_tHttpResponse.Data.Read()
		} Else {
			Set tErrorMessage = $$$StatusDisplayString(tStatus)
		}
		Set tErrorResponseStream = ..CreateJSONErrorResponse(tErrorMessage)
		Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
		Do pResponse.JSONStream.CopyFrom(tErrorResponseStream)
		
		Set tStatus = $$$OK	
	}
	Quit tStatus
}

/// Send the request
Method SendPUTRequest(
	pRequest As IHC.EAI.Uptime.Message.Request,
	Output pResponse As IHC.EAI.Uptime.Message.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set pResponse = ##class(IHC.EAI.KPI.Message.Response).%New()
		Set tURL = ..Adapter.URL
		Set:(pRequest.URL '= "") tURL = pRequest.URL
		Set tStatus = ..Adapter.PutURL(tURL,.tHttpResponse,"",pRequest.JSONStream)
		If ($$$ISERR(tStatus) && $IsObject(tHttpResponse) && $IsObject(tHttpResponse.Data) && tHttpResponse.Data.Size) {
			Set tStatus = $$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(tStatus)_":"_tHttpResponse.Data.Read())
		}
		$$$ThrowOnError(tStatus)
		If ($$$IsdefObject(tHttpResponse)) {
			Do tHttpResponse.Data.Rewind()
			Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
			Do pResponse.JSONStream.CopyFrom(tHttpResponse.Data)
		} 
	} Catch eException {
		Set tStatus = eException.AsStatus()
		
		Set tErrorMessage = ""
		If ($IsObject(tHttpResponse) && $IsObject(tHttpResponse.Data) && tHttpResponse.Data.Size) {
			Set tErrorMessage = $$$StatusDisplayString(tStatus)_":"_tHttpResponse.Data.Read()
		} Else {
			Set tErrorMessage = $$$StatusDisplayString(tStatus)
		}
		Set tErrorResponseStream = ..CreateJSONErrorResponse(tErrorMessage)
		Set pResponse.JSONStream = ##class(%Stream.GlobalCharacter).%New()
		Do pResponse.JSONStream.CopyFrom(tErrorResponseStream)
		
		Set tStatus = $$$OK	
	}
	Quit tStatus
}

ClassMethod CreateJSONErrorResponse(
	pErrorMessage As %String,
	Output pStatus As %Status = {$$$OK}) As %Stream.GlobalCharacter
{
	Set tStream = ""
	Try {
		Set tStream = ##class(%Stream.GlobalCharacter).%New()
		Do tStream.Write("{")
		Do tStream.Write("""success"": false,")
		Do tStream.Write("""message"": """ _ pErrorMessage _ """")
		Do tStream.Write("}")
		Do tStream.Rewind()
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tStream
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	Set tStatus = $$$OK, tCredObj = ""
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
