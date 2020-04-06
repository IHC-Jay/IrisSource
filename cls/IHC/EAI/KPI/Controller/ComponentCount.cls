/// Class that stores a snaphsot of daily component count data
Class IHC.EAI.KPI.Controller.ComponentCount Extends (%RegisteredObject, Ens.Util.JSON, IHC.EAI.Common.Util)
{

Parameter MetricsService = "IHC.EAI.KPI.Service.Metrics";

Parameter MetricsRequestName = "ComponentCount";

Parameter MetricsAPIURL = "/eai/MetricsAPI/count/component/";

/// Create the snapshots
ClassMethod CreateSnapshots(Output pJSONStream As %Stream.GlobalCharacter, pCountType = "", pCountDate As %Date = { ($ZDH($ZD($H,3),3))}, pSendSnapshots As %Boolean = 0, pDebug As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	
	Try {
		
		// Run for all namespaces
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		// Create the JSON container stream
		Set pJSONStream = ##class(%Stream.GlobalCharacter).%New()
		Do pJSONStream.Write("[")
		
		// Loop through namespace list
		Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
		
		Set tIsFirst = 1
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = tResultSet.%GetData(1)
			
			Set tJSONObj = ""
			
			Do:'(tIsFirst) pJSONStream.Write(",")
			
			// Create the snapshot per namespace
			If (pCountType = "") {
				Set tInJSONObj = ..CreateSnapshot(tNamespace,"Total",pCountDate,pDebug,.tStatus)
				$$$ThrowOnError(tStatus)
				Set tStatus = ..ObjectToJSONStream(tInJSONObj,.tInJSONObjStream,"aiw")
				$$$ThrowOnError(tStatus)
				Do pJSONStream.CopyFrom(tInJSONObjStream)
				
				Do pJSONStream.Write(",")
				
				Set tOutJSONObj = ..CreateSnapshot(tNamespace,"Enabled",pCountDate,pDebug,.tStatus)
				$$$ThrowOnError(tStatus)
				Set tStatus = ..ObjectToJSONStream(tOutJSONObj,.tOutJSONObjStream,"aiw")
				$$$ThrowOnError(tStatus)
				Do pJSONStream.CopyFrom(tOutJSONObjStream)
				
				Do pJSONStream.Write(",")
				
				Set tOutJSONObj = ..CreateSnapshot(tNamespace,"Disabled",pCountDate,pDebug,.tStatus)
				$$$ThrowOnError(tStatus)
				Set tStatus = ..ObjectToJSONStream(tOutJSONObj,.tOutJSONObjStream,"aiw")
				$$$ThrowOnError(tStatus)
				Do pJSONStream.CopyFrom(tOutJSONObjStream)
				
			} Else {
				Do:('tIsFirst) pJSONStream.Write(",")
				
				// Write JSON out to array stream
				Set tJSONObj = ..CreateSnapshot(tNamespace,pCountType,pCountDate,pDebug,.tStatus)
				$$$ThrowOnError(tStatus)
				Set tStatus = ..ObjectToJSONStream(tJSONObj,.tJSONObjStream,"aiw")
				$$$ThrowOnError(tStatus)
				Do pJSONStream.CopyFrom(tJSONObjStream)
			}
			
			Set:(tIsFirst) tIsFirst = 0
		}
		$$$ThrowOnError(tStatus)
		
		Do pJSONStream.Write("]")
		
		If (pSendSnapshots) {
			// Send all snapshots to the business service
			Set tStatus = ..SendSnapshot(pJSONStream)
			$$$ThrowOnError(tStatus)
		}
			
	} Catch eException {
		Set tStatus = eException.AsStatus()	
	}
	Quit tStatus
}

/// Create a Transaction Count Snapshot<br/>
/// 	Params:<br/>
/// 		pCountType:<br/>
/// 			Total (Default)<br/>
/// 			Enabled<br/>
/// 			Disabled<br/>
/// 		pCountDate:<br/>
/// 			Format is Cache internal format<br/>
/// 			Example: 64098<br/>
/// 			If empty, process count for yesterday<br/>
/// Do ##class(IHC.EAI.KPI.Controller.TransactionCount).CreateSnapshot("",,,1)
ClassMethod CreateSnapshot(pNamespace As %String, pCountType As %String = "Total", pCountDate As %Date = { ($ZDH($ZD($H,3),3))}, pDebug As %Boolean = 0, pStatus As %Status = {$$$OK}) As IHC.EAI.KPI.JSON.TransactionCount
{
	Set tSnapshotJSON = ""
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Kill:(pDebug) ^EAI.Debug.TransactionCount
		
		Set tCurrentDatetime = $ZDATETIME($H,3)
		
		Set tSnapshotJSON = ..CreateSnapshotJSON(pCountType,pCountDate,tCurrentDatetime,pDebug,.pStatus)
		$$$ThrowOnError(pStatus)

	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tSnapshotJSON
}

ClassMethod CreateSnapshotJSON(pCountType As %String = "Total", pCountDate As %Date, pCurrentDatetime As %TimeStamp, pDebug As %Boolean = 0, Output pStatus As %Status = {$$$OK}) As IHC.EAI.KPI.JSON.ComponentCount
{
	Set tSnapshotJSON = ""
	
	Try {
		Set tSnapshotJSON = ##class(IHC.EAI.KPI.JSON.ComponentCount).%New()
		Set tSnapshotJSON.createdOn = pCurrentDatetime
		Set tSnapshotJSON.application = "Ensemble"
		Set tSnapshotJSON.group = $NAMESPACE
		Set tSnapshotJSON.valueDate = $ZD(pCountDate,3)
		Set tSnapshotJSON.type = pCountType
		
		// Component counts
		Set tSnapshotJSON.value = ..GetComponentCount(pCountType,.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set:(pDebug) ^EAI.Debug.ComponentCount($NAMESPACE,pCountDate,pCountType,"Value") = tSnapshotJSON.value
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tSnapshotJSON
}

ClassMethod SendSnapshot(pJSONStream As %Stream.GlobalCharacter) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tRequest = ##class(IHC.EAI.KPI.Message.Request).%New()
		Set tRequest.Command = "PUT"
		Set tRequest.Name = ..#MetricsRequestName
		Set tRequest.URL = ..#MetricsAPIURL	// CONFIG?
		Set tRequest.JSONStream = ##class(%Stream.GlobalCharacter).%New()
		Set tStatus = tRequest.JSONStream.CopyFrom(pJSONStream)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(Ens.Director).CreateBusinessService(..#MetricsService,.tBusSvc)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = tBusSvc.ProcessInput(tRequest,.tResponse)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Retrieve the total number of Ensemble components for the current namespace
ClassMethod GetComponentCount(pCountType As %String = "", Output pStatus As %Status = {$$$OK}) As %Integer
{
	Set tCount = 0
	Try {
		Set SQLCODE = ""
		If (pCountType = "Enabled") {
			&sql(SELECT COUNT(%Id) INTO :tCount FROM Ens_Config.Item WHERE Enabled = 1)
		} ElseIf (pCountType = "Disabled") {
			&sql(SELECT COUNT(%Id) INTO :tCount FROM Ens_Config.Item WHERE Enabled = 0)
		} Else {
			&sql(SELECT COUNT(%Id) INTO :tCount FROM Ens_Config.Item)
		}
		If (SQLCODE '= 0) {
			$$$ThrowStatus($$$ERROR($$$SQLError, "Component Count query failed. pEnabled:" _ pEnabled))	
		}
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tCount
}

}