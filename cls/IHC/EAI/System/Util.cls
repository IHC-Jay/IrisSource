Class IHC.EAI.System.Util Extends IHC.EAI.Log.Util
{

Parameter LOGNAME = "EAI.SystemUtil";

ClassMethod DoPostUpgradeTasks() As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Compile all
		Set tStatus = $System.OBJ.CompileAllNamespaces("ck")
		If ($$$ISERR(tStatus)) {
			Set tErrorText = $System.Status.GetErrorText(tStatus)
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","CompileAll|"_tErrorText)
			Set tStatus = $$$OK
		} Else {
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","CompileAll|Completed successfully.")
		}
		
		// Load the Adhoc17043 patch
		Set tPatchDir = $System.Util.InstallDirectory() _ "mgr/iscpatches/Adhoc17043/"
		Set tStatus = $System.OBJ.LoadDir(tPatchDir,"ck",.tErrorLog,1,.tLoadedList)
		If ($$$ISERR(tStatus)) {
			Set tErrorText = $System.Status.GetErrorText(tStatus)
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","Adhoc17043|"_tErrorText)
			Set tStatus = $$$OK
		} Else {
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","Adhoc17043|Completed successfully.")
		}
		
		// Export/import schemas
		Set tStatus = ##class(IHC.EAI.HL7.Schema.Util).RefreshSchemas()
		If ($$$ISERR(tStatus)) {
			Set tErrorText = $System.Status.GetErrorText(tStatus)
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","RefreshSchemas|"_tErrorText)
			Set tStatus = $$$OK
		} Else {
			Do ..Log(.tLogFile,..%ClassName(1),"BuildAll","RefreshSchemas|Completed successfully.")
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod CompileItems(pItem As %String,pIsPackage As %Boolean = 0,pNamespace As %String = "EAI") As %Status {
	Try {
		
		If ((pNamespace = "") || ($ZCONVERT(pNamespace,"U") = "ALL")) {
			
			// Loop over known namespaces and trigger a compile of the resource
			// Run for all namespaces
			Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
			$$$ThrowOnError(tStatus)
			
			// Loop through namespace list
			Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
			Set tStatement = ##class(%SQL.Statement).%New()
			Set tStatus = tStatement.%Prepare(tQuery)
			$$$ThrowOnError(tStatus)
			Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
			
			While (tResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)
				
				Set tNamespace = tResultSet.%GetData(1)
				
				Set tStatus = ..CompileItem(pItem,pIsPackage,tNamespace)
				$$$ThrowOnError(tStatus)
			}
			$$$ThrowOnError(tStatus)
		} Else {
			// Compile only in the specified namespace, usually EAI
			Set tStatus = ..CompileItem(pItem,pIsPackage,pNamespace)
			$$$ThrowOnError(tStatus)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod CompileItem(pItem As %String,pIsPackage As %Boolean = 0,pNamespace As %String) As %Status {
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		If (pIsPackage) {
			Set tStatus = $System.OBJ.CompilePackage(pItem,"cbk")
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = $System.OBJ.Compile(pItem,"cbk")
			$$$ThrowOnError(tStatus)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}
}
