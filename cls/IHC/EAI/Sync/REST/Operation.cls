Class IHC.EAI.Sync.REST.Operation Extends EnsLib.REST.Operation {

Method OnMessage(
	pRequest As IHC.EAI.Sync.REST.Request,
	Output pResponse As IHC.EAI.Sync.REST.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// PUT - GET - POST - DELETE
		Set tCommand = $ZCONVERT(pRequest.Command,"U")
		Set tSyncType = $ZCONVERT(pRequest.SyncType,"L")
		
		If (tCommand = "PUT") {
			If (tSyncType = "ssl") {
				Set tStatus = ..PUTSSLConfigs(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "tasks") {
				Set tStatus = ..PUTTasks(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "hl7schemas") {
				Set tStatus = ..PUTHL7Schemas(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "sqlgateway") {
				Set tStatus = ..PUTSQLG(pRequest)
				$$$ThrowOnError(tStatus)
			} Else {
				$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Sync Type " _ pRequest.SyncType _ " not implemented"))
			}
		} ElseIf (tCommand = "GET") {
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Command 'GET' not implemented"))
		} ElseIf (tCommand = "POST") {
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Command 'POST' not implemented"))
		} ElseIf (tCommand = "DELETE") {
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Command 'DELETE' not implemented"))
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Command '" _ pRequest.Command _ "' not implemented"))
		} 
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Method PUTSSLConfigs(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {
	
	Set tStatus = $$$OK
	
	// Create the repsonse object
	Set pResponse = ##class(IHC.EAI.Sync.REST.Response).%New()
		
	Try {
	
		Set:(pRequest.Server '= "") ..Adapter.HTTPServer = pRequest.Server
		Set:(pRequest.Port '= "") ..Adapter.HTTPPort = pRequest.Port
		
		Set tURL = ..Adapter.URL
		Set:(pRequest.URL '= "") tURL = pRequest.URL
		
		Set tStatus = ..Adapter.PutURL(tURL,.tHttpResponse,"",pRequest.JSONContent)
		If (($$$ISERR(tStatus)) && ($IsObject(tHttpResponse)) && ($IsObject(tHttpResponse.Data)) && (tHttpResponse.Data.Size)) {
			// Received an error and response data
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(tStatus)_":"_tHttpResponse.Data.Read()))
		}
		
		Set pResponse.RawResponse = ##class(%Stream.GlobalCharacter).%New()
		Set pResponse.SessionId = ..%RequestHeader.SessionId
		Set pResponse.RequestURL = "Put " _ tURL
		
		If ($$$IsdefObject(tHttpResponse)) {
			Do pResponse.RawResponse.CopyFrom(tHttpResponse.Data)
			Do tHttpResponse.Data.Rewind()
			Set pResponse.Value = tHttpResponse.Data.Read()
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrGeneral,"Null response object and no system error."))
		}
		
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
		Set tErrorMessage = $System.Status.GetErrorText(tStatus)
		Set pResponse.Value = tErrorMessage
		Do pResponse.RawResponse.Write("{""success"": false,""message"":""" _ tErrorMessage _ """}")

		// force ok return
		Set tStatus = $$$OK
	}
	Quit tStatus
}

Method PUTTasks(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}

Method PUTHL7Schemas(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}

Method PUTSQLG(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}

}