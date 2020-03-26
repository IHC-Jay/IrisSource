Class IHC.EAI.HL7.Purge.Util Extends IHC.EAI.Log.Util
{

Parameter LOGNAME = "EAI.HL7.Purge";

/// Write ##class(IHC.EAI.HL7.Purge.Util).PurgeOrphanedHL7(.tCount,.tLogFile,1,0)
ClassMethod PurgeOrphanedHL7(Output pMessageCount As %Integer, Output pLogFile As %File, pLogLevel As %Integer = 0, pDoPurge As %Boolean = 0) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","---BEGIN: " _ $ZDT($H,3) _ "---")
	
	Set tStatus = $$$OK, pMessageCount = 0
	Try {
		
		Set tPurgeList = ##class(%ListOfDataTypes).%New()
		
		// Grab all hl7 message bodies
		Set tQuery = "SELECT %Id FROM EnsLib_Hl7.Message"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		
		Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Building the purge list...")
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tMessageBodyId = tResultSet.%GetData(1)
			
			Set SQLCODE = "", tMessageHeaderId = -1
			&sql(SELECT %Id INTO :tMessageHeaderId FROM Ens.MessageHeader WHERE MessageBodyId = :tMessageBodyId)
			If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to query message header table for body id: " _ tMessageBodyId))
			}
			If (tMessageHeaderId = -1) {
				//	orphaned - delete it
				Do tPurgeList.Insert(tMessageBodyId)
				Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Purging:" _ tMessageBodyId)
				
				Set:('pDoPurge) pMessageCount = pMessageCount + 1
			} Else {
				Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Purge","Skipping:" _ tMessageBodyId)
			}
		}
		$$$ThrowOnError(tStatus)	
		
		If (pDoPurge) {
			Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Beginning the purge...")
			For i=1:1:tPurgeList.Count() {
				Set tPurgeBodyId = tPurgeList.GetAt(i)
				Set SQLCODE = ""
				&sql(DELETE FROM EnsLib_Hl7.Message WHERE %Id = :tPurgeBodyId)
				If (SQLCODE '= 0) {
					$$$ThrowStatus($$$ERROR($$$GeneralError, "Error occurred purging body id: " _ tPurgeBodyId))
				}
				Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Purge","Successfully purged message body id: " _ tPurgeBodyId)
				Set pMessageCount = pMessageCount + 1
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
		Set tErrorMessage = $System.Status.GetErrorText(tStatus)
		Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Error: " _ tErrorMessage)
	}
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","---END: " _ $ZDT($H,3) _ "---")
	
	Quit tStatus
}

/// Write ##class(IHC.EAI.HL7.Purge.Util).PurgeOrphanedHL7MBK(.tCount,.tLogFile,1,0)
ClassMethod PurgeOrphanedHL7MBK(Output pMessageCount As %Integer, Output pLogFile As %File, pLogLevel As %Integer = 0, pDoPurge As %Boolean = 0) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","---BEGIN: " _ $ZDT($H,3) _ "---")
	
	Set tStatus = $$$OK
	Try {
		
		Set tPurgeList = ##class(%ListOfDataTypes).%New()
		
		// Grab all hl7 message bodies
		Set tQuery = "SELECT %Id FROM EnsLib_Hl7.Message"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		
		Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Building the purge list...")
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tMessageBodyId = tResultSet.%GetData(1)
			
			Set SQLCODE = "", tMessageHeaderId = -1
			&sql(SELECT %Id INTO :tMessageHeaderId FROM Ens_Enterprise_MsgBank.MessageHeader WHERE MessageBodyId = :tMessageBodyId)
			If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to query message header table for body id: " _ tMessageBodyId))
			}
			If (tMessageHeaderId = -1) {
				//	orphaned - delete it
				Do tPurgeList.Insert(tMessageBodyId)
				Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Purging:" _ tMessageBodyId)
			} Else {
				Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Purge","Skipping:" _ tMessageBodyId)
			}
		}
		$$$ThrowOnError(tStatus)	
		
		If (pDoPurge) {
			Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Beginning the purge...")
			For i=1:1:tPurgeList.Count() {
				Set tPurgeBodyId = tPurgeList.GetAt(i)
				Set SQLCODE = ""
				&sql(DELETE FROM EnsLib_Hl7.Message WHERE %Id = :tPurgeBodyId)
				If (SQLCODE '= 0) {
					$$$ThrowStatus($$$ERROR($$$GeneralError, "Error occurred purging body id: " _ tPurgeBodyId))
				}
				Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Purge","Successfully purged message body id: " _ tPurgeBodyId)
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
		Set tErrorMessage = $System.Status.GetErrorText(tStatus)
		Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","Error: " _ tErrorMessage)
	}
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Purge","---END: " _ $ZDT($H,3) _ "---")
	
	Quit tStatus
}

}
