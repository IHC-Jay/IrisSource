Class IHC.EAI.Sync.REST.Process Extends Ens.BusinessProcess {

Parameter SETTINGS = "TargetConfigName";

Parameter BaseServiceURL = "/sync/";

/// Target Config
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.Sync.REST.Operation" ];

/// Handle monitor requests
Method OnRequest(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Verify this is a primary mirror member
		If (($System.Mirror.IsMember()) && ($System.Mirror.IsPrimary())) {
		
			// Get the sync type for this request
			Set tSyncType = $ZCONVERT(pRequest.SyncType,"L")
			If (tSyncType = "all") {
				Set tStatus = ..SyncAll(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "ssl") {
				Set tStatus = ..SyncSSLConfigs(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "tasks") {
				Set tStatus = ..SyncTasks(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "hl7schemas") {
				Set tStatus = ..SyncHL7Schemas(pRequest)
				$$$ThrowOnError(tStatus)
			} ElseIf (tSyncType = "sqlgateway") {
				Set tStatus = ..SyncSQLG(pRequest)
				$$$ThrowOnError(tStatus)
			} Else {
				$$$ThrowStatus($$$ERROR($$$EnsErrGeneral, "Sync Type " _ pRequest.SyncType _ " not implemented"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Not a primary mirror member."))
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Method SyncAll(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}

Method SyncSSLConfigs(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {
	#Dim tBackupMemberList As %ListOfDataTypes
	
	Set tStatus = $$$OK
	Try {
		Set tSSLConfigs = ##class(IHC.EAI.Sync.Util).GetSSLConfigs(.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set tJSON = tSSLConfigs.%ToJSON()
		
		Set tJSONContent = ##class(%Stream.GlobalCharacter).%New()
		Set tStatus = tJSONContent.Write(tJSON)
		$$$ThrowOnError(tStatus)
		Do tJSONContent.Rewind()
		
		// Set the location info
		Set tProperties = ""
		Set tStatus = ##class(IHC.EAI.Sync.Util).GetBackupMemberInfo(.tBackupMemberList)
		$$$ThrowOnError(tStatus)
		
		// Loop over backup members, issuing a sync call to each
		For i=1:1:tBackupMemberList.Count() {
			Set tBackupMemberItem = tBackupMemberList.GetAt(i)
			Set tSSLSyncRequest = ##class(IHC.EAI.Sync.REST.Request).%New()
			Set tSSLSyncRequest.Command = pRequest.Command
			Set tSSLSyncRequest.SyncType = pRequest.SyncType
			Set tSSLSyncRequest.JSONContent = tJSONContent
			
			
			Set tURL = ..#BaseServiceURL
			Set tURLLastChar = $EXTRACT(tURL,($LENGTH(tURL)-1),$LENGTH(tURL))
			Set:(tURLLastChar '= "/") tURL = tURL _ "/"
		
			Set tURL = tURL _ $ZCONVERT(pRequest.SyncType,"L")
			
			Set tSSLSyncRequest.URL = tURL
			Set tSSLSyncRequest.Server = $PIECE(tBackupMemberItem,"|",1)
			Set tSSLSyncRequest.Port = $PIECE(tBackupMemberItem,"|",2)
			
			Set tStatus = ..SendRequestSync(..TargetConfigName,pRequest,.pResponse)
			$$$ThrowOnError(tStatus)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Method SyncTasks(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}
Method SyncHL7Schemas(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}
Method SyncSQLG(pRequest As IHC.EAI.Sync.REST.Request, Output pResponse As IHC.EAI.Sync.REST.Response) As %Status {}


Storage Default
{
<Data name="ProcessDefaultData">
<Subscript>"Process"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
</Data>
<DefaultData>ProcessDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}