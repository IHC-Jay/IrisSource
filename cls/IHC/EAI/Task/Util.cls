Class IHC.EAI.Task.Util Extends IHC.EAI.Log.Util {

/// Export all user tasks
ClassMethod ExportAll(pDir As %String = "/itf-share/itf-tmp/",Output pFileName As %String = "") As %Status {
	
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		// Establish filename
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set pFileName = ##class(%File).NormalizeFilename(tInstanceType _ "_AllTasks.xml",pDir)
		
		// Loop through namespace list
		//Set tQuery = "SELECT ID FROM %SYS.Task WHERE Type = 2"
		Set tQuery = "SELECT ID FROM %SYS.Task"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		
		Set tIDString = ""
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tTaskID = tResultSet.%GetData(1)
			
			If ($LENGTH(tIDString) = 0) {
				Set tIDString = tTaskID
			} Else {
				Set tIDString = tIDString _ "," _ tTaskID
			}
		}
		$$$ThrowOnError(tStatus)
		
		If ($LENGTH(tIDString) > 0) {
			Set tIDList = $LISTFROMSTRING(tIDString,",")
			
			Set tStatus = ##class(%SYS.Task).ExportTasks(tIDList,pFileName)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Import all tasks
ClassMethod ImportAll(pFilename As %String = "") As %Status {
	
	Set tStatus = $$$OK
	Try {
	
		Set tStatus = ##class(%SYS.Task).ImportTasks(pFilename)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}