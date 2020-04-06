/// REST service API for ITF BI Health Check
Class IHC.EAI.Monitor.Service.API Extends EnsLib.REST.Service
{

Parameter ADAPTER;

Parameter EnsServicePrefix = "|";

XData UrlMap
{
<Routes>
<Route Url="/mirror/backup-info/" Method="GET" Call="GetMirrorBackupInfo"/>
<Route Url="/mirror/status/" Method="GET" Call="GetMirrorStatus"/>
</Routes>
}

/// API method to obtain the names of any backup and async instances
Method GetMirrorBackupInfo(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try { 
		// Create a list of datatypes
		Set tBackupList = ##class(%ListOfDataTypes).%New()
		
		// Security is setup in %SYS namespace
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
   		
		Set tResultSet = ##class(%ResultSet).%New("SYS.Mirror:MemberStatusList")
		Set tStatus = tResultSet.Execute()
		$$$ThrowOnError(tStatus)
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			Set tName = tResultSet.%Get("MemberName")
			Set tRole = tResultSet.%Get("CurrentRole")
			If ((tRole = "Backup") || (tRole = "Async")) {
				Set tMemberString = tName _ "|" _ tRole
				Do tBackupList.Insert(tMemberString)
			}
		}
		$$$ThrowOnError(tStatus)
		Kill tResultSet
		
		Set tStatus = ..ObjectToJSONStream(tBackupList,.tOutputStream,"aiw")
		$$$ThrowOnError(tStatus)
		
		Do pOutput.SetAttribute("Content-Type","application/json")
		Do pOutput.CopyFrom(tOutputStream)
		
	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

/// This method provides a service
Method GetMirrorStatus(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set tStatus = $$$OK
	Try { 
		// 
		//$$$LOGINFO(pInput.Read(100))
		Set tMemberStatusList = ##class(%ListOfObjects).%New()
		
		// Security is setup in %SYS namespace
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
   		
		Set tResultSet = ##class(%ResultSet).%New("SYS.Mirror:MemberStatusList")
		Set tStatus = tResultSet.Execute()
		$$$ThrowOnError(tStatus)
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			// Grab the values
			Set tMemberStatus = ##class(IHC.EAI.Monitor.Mirror.JSON.MemberStatus).%New()
			Set tMemberStatus.memberName = tResultSet.%Get("MemberName")
			Set tMemberStatus.currentRole = tResultSet.%Get("CurrentRole")
			Set tMemberStatus.currentStatus = tResultSet.%Get("CurrentStatus")
			Set tMemberStatus.journalLatency = tResultSet.%Get("JournalLatency")
			Set tMemberStatus.databaseLatency = tResultSet.%Get("DatabaseLatency")
			Set tMemberStatus.journalTimeLatency = tResultSet.%Get("JournalTimeLatency")
			Set tMemberStatus.databaseTimeLatency = tResultSet.%Get("DatabaseTimeLatency")
			Set tMemberStatus.displayType = tResultSet.%Get("DisplayType")
			Set tMemberStatus.displayStatus = tResultSet.%Get("DisplayStatus")
			
			Set tStatus = tMemberStatusList.Insert(tMemberStatus)
		}
		$$$ThrowOnError(tStatus)

		Set tStatus = ..ObjectToJSONStream(tMemberStatusList,.tOutputStream,"aiw")
		$$$ThrowOnError(tStatus)
		
		Do pOutput.SetAttribute("Content-Type","application/json")
		Do pOutput.CopyFrom(tOutputStream)

	} Catch (eException) {
		Set tStatus = eException.AsStatus()
	}
	
    Quit tStatus
}

}
