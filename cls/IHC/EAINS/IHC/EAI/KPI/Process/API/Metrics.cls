/// Metrics business process
Class IHC.EAI.KPI.Process.API.Metrics Extends (Ens.BusinessProcess, Ens.Util.JSON)
{

/// Handle metrics requests
Method OnRequest(pRequest As %Library.Persistent, Output pResponse As %Library.Persistent) As %Status
{
	Set tStatus = $$$OK
	Try {
		If (pRequest.%IsA("IHC.EAI.KPI.Message.API.Request")) {
			If (pRequest.Name = "TransactionCount") {
				Set tStatus = ..CreateTransactionCount(pRequest.JSONStream,.pResponse)
				$$$ThrowOnError(tStatus)
			} ElseIf (pRequest.Name = "ComponentCount") {
				Set tStatus = ..CreateComponentCount(pRequest.JSONStream,.pResponse)
				$$$ThrowOnError(tStatus)
			} Else {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Request type not supported: " _ pRequest.Name))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrRequestNotHandled, pRequest.%ClassName(1)))
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// This method creates a Transaction Count record <br/>
ClassMethod CreateTransactionCount(pRequest As %Stream.GlobalCharacter, Output pResponse As IHC.EAI.KPI.Message.API.Response) As %Status
{
	#Dim tInboundTC As IHC.EAI.KPI.JSON.TransactionCount
	
	Set tStatus = $$$OK
	Try {
		Set pResponse = ##class(IHC.EAI.KPI.Message.API.Response).%New()
		Set tStream = ##class(%Stream.GlobalBinary).%New()
		// Transform inbound json to transaction count
		Set tInboundTCArray = ""
		Set tStatus = ..JSONStreamToObjectArray(pRequest,.tInboundTCArray)
		$$$ThrowOnError(tStatus)
		
		If ($DATA(tInboundTCArray) = 11) {
			Set tMessage = "", tRecordIdList = ""
			
			Set tKey = $ORDER(tInboundTCArray(""))
			While (tKey '= "") {
				
				Set tTransactionCount = ##class(IHC.EAI.KPI.Util.Metrics).AddUpdateTransCount(tInboundTCArray(tKey),.tStatus)
				$$$ThrowOnError(tStatus)
				
				If ($$$ISERR(tStatus)) {
					If (tMessage '= "") {
						Set tMessage = tMessage _ "|" _ $$$StatusDisplayString(tStatus)
					} Else {
						Set tMessage = $$$StatusDisplayString(tStatus)
					}
					Set tStatus = $$$OK
				}
				
				If ($$$IsdefObject(tTransactionCount)) {
					If (tRecordIdList '= "") {
						Set tRecordIdList = tRecordIdList _ "|" _ tTransactionCount.%Id()
					} Else {
						Set tRecordIdList = tTransactionCount.%Id()
					}
				}
				Set tKey = $ORDER(tInboundTCArray(tKey))
			}
			
			Set:(tMessage = "") tMessage = "Success"
			
			Set pResponse.RecordIdList = tRecordIdList
			Set pResponse.Message = tMessage
		}
 		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

/// This method creates a Component Count record <br/>
ClassMethod CreateComponentCount(pRequest As %Stream.GlobalCharacter, Output pResponse As IHC.EAI.KPI.Message.API.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set pResponse = ##class(IHC.EAI.KPI.Message.API.Response).%New()
		Set tStream = ##class(%Stream.GlobalBinary).%New()
		// Transform inbound json to transaction count
		Set tInboundTCArray = ""
		Set tStatus = ..JSONStreamToObjectArray(pRequest,.tInboundTCArray)
		$$$ThrowOnError(tStatus)
		
		If ($DATA(tInboundTCArray) = 11) {
			Set tMessage = "", tRecordIdList = ""
			
			Set tKey = $ORDER(tInboundTCArray(""))
			While (tKey '= "") {
				
				Set tComponentCount = ##class(IHC.EAI.KPI.Util.Metrics).AddUpdateCompCount(tInboundTCArray(tKey),.tStatus)
				$$$ThrowOnError(tStatus)
				
				If ($$$ISERR(tStatus)) {
					If (tMessage '= "") {
						Set tMessage = tMessage _ "|" _ $$$StatusDisplayString(tStatus)
					} Else {
						Set tMessage = $$$StatusDisplayString(tStatus)
					}
					Set tStatus = $$$OK
				}
				
				If ($$$IsdefObject(tComponentCount)) {
					If (tRecordIdList '= "") {
						Set tRecordIdList = tRecordIdList _ "|" _ tComponentCount.%Id()
					} Else {
						Set tRecordIdList = tComponentCount.%Id()
					}
				}
				
				Set tKey = $ORDER(tInboundTCArray(tKey))
			}
			
			Set:(tMessage = "") tMessage = "Success"
			
			Set pResponse.RecordIdList = tRecordIdList
			Set pResponse.Message = tMessage
		}
		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
