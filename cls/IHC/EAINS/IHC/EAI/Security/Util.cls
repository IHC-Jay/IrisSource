/// Class that manages ITF security setups and configurations<br/>
Class IHC.EAI.Security.Util Extends IHC.EAI.Log.Util
{

Parameter LOGNAME = "EAI.Security";

/// Set tStatus = ##class(IHC.EAI.Security.Util).UpdateSecurity("DirToInitJSON")
ClassMethod UpdateSecurity(pDir As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ..Log(.tLogFile,..%ClassName(1),"UpdateSecurity","Begin update security") $$$ThrowOnError(tStatus)
		Set tStatus = ..Log(.tLogFile,..%ClassName(1),"UpdateSecurity","JSON Dir: " _ pDir) $$$ThrowOnError(tStatus)
		
		// Get the env info
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ..Log(.tLogFile,..%ClassName(1),"UpdateSecurity","Env|InstType|InstName: " _ tEnvironment _ "|" _ tInstanceType _ "|" _ tInstanceName) $$$ThrowOnError(tStatus)
		
		// Update settings from json files
		Set tStatus = ..UpdateSecuritySettings(pDir,tEnvironment,tInstanceType,.tLogFile)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ..Log(.tLogFile,..%ClassName(1),"UpdateSecurity","End update security") $$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod UpdateSecuritySettings(pDir As %String, pEnvironment As %String, pInstanceType As %String, ByRef pLogFile As %File) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	
	Set tStatus = $$$OK
	Try {
	
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Begin update security settings") $$$ThrowOnError(tStatus)
		
		// System Resource
		Set tStatus = ##class(IHC.EAI.Security.Schema.Resource).DeployResources(pDir,"system_resources.json",pEnvironment,pInstanceType,.pLogFile)
		$$$ThrowOnError(tStatus)
		
		// ITF Resource
		Set tStatus = ##class(IHC.EAI.Security.Schema.Resource).DeployResources(pDir,"itf_resources.json",pEnvironment,pInstanceType,.pLogFile)
		$$$ThrowOnError(tStatus)
		
		// ITF Roles
		If ($GET(^EAI.Security("ITFRole","Skip")) '= 1) {
			Set tStatus = ##class(IHC.EAI.Security.Schema.ITFRole).DeployITFRoles(pDir,"itf_roles.json",pEnvironment,pInstanceType,.pLogFile)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Per global, skipping DeployITFRoles") $$$ThrowOnError(tStatus)
		}
		
		// ITF Users
		If ($GET(^EAI.Security("ITFUser","Skip")) '= 1) {
			Set tStatus = ##class(IHC.EAI.Security.Schema.ITFUser).DeployITFUsers(pDir,"itf_users.json",pEnvironment,pInstanceType,.pLogFile)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Per global, skipping DeployITFUsers") $$$ThrowOnError(tStatus)
		}
		
		// ITF Portal (Custom) Resource assignments
		If ($GET(^EAI.Security("PortalResourceAssignment","Skip")) '= 1) {
			Set tStatus = ##class(IHC.EAI.Security.Schema.PortalResource).DeployPortalResourceAssignments(pDir,"portal_itfresources.json",pEnvironment,pInstanceType,.pLogFile)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Per global, skipping DeployPortalResourceAssignments") $$$ThrowOnError(tStatus)
		}
		
		// SQL Privileges
		If ($GET(^EAI.Security("SQLPrivilege","Skip")) '= 1) {
			Set tStatus = ##class(IHC.EAI.Security.Schema.SQLPrivilege).DeploySQLPrivileges(pDir,"sql_privileges.json",pEnvironment,pInstanceType,.pLogFile)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Per global, skipping DeploySQLPrivileges") $$$ThrowOnError(tStatus)
		}
		
		// Custom SQL Privileges
		If ($GET(^EAI.Security("CustomSQLPrivilege","Skip")) '= 1) {
			Set tStatus = ##class(IHC.EAI.Security.Schema.SQLPrivilegeCustom).DeployCustomSQLPrivileges(pDir,"sql_privileges_custom.json",pEnvironment,pInstanceType,.pLogFile)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","Per global, skipping DeployCustomSQLPrivileges") $$$ThrowOnError(tStatus)
		}
		
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","End update security settings") $$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
		Set tErrorMessage = $System.Status.GetErrorText(tStatus)
		Do ..Log(.pLogFile,..%ClassName(1),"UpdateSecuritySettings","ERROR: " _ tErrorMessage)
	}
	Quit tStatus
}

ClassMethod CheckPrivileges() As %Status
{
	Set tStatus = $$$OK
	Try {
		// First check that we have %Admin_Security:USE privilige
		If ('$System.Security.Check("%Admin_Security","Use")) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"You do not have %Admin_Security:USE privileges"))
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()	
	}
	Quit tStatus
}

ClassMethod GetNamespaceList(Output pNamespaceList As %ListOfDataTypes) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
			
	Set tStatus = $$$OK
	Try {
		
		Set pNamespaceList = ##class(%ListOfDataTypes).%New()
		
		If ($NAMESPACE '= "EAI") {
			New $NAMESPACE
		   	Set $NAMESPACE = "EAI"
		}
		
		// Get the env info
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		// From eai 
		Set tQuery = "SELECT Namespace FROM IHC_EAI_System_Data.Namespace WHERE InstanceName = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tInstanceName)
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = tResultSet.%GetData(1)
			
			Do pNamespaceList.Insert(tNamespace)
		}
		$$$ThrowOnError(tStatus)
		
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetLocalDatabasePackages(pNamespace As %String,pDatabase As %String, pRootPackage As %String = "*", ByRef pList As %ListOfDataTypes) As %Status {
	Set tStatus = $$$OK 
	Try {
	
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
   		
		// Assign all local packages (includes sub packages)
		Set tCall = "Call Config.MapPackages_ListPackages(?)"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set tStatus = tStatement.%Prepare(tCall)
  		$$$ThrowOnError(tStatus)
  		Set tResultSet = tStatement.%Execute(pDatabase)
  		While tResultSet.%Next(.tStatus) {
			$$$ThrowOnError(tStatus)
			
			Set tPackage = tResultSet.%Get("Name")
			
			If (pRootPackage '= "*") {
				Set tEvalRootPackage = pRootPackage _ "."
				Set tFindRootPackage = $FIND(tPackage,tEvalRootPackage)	// Is a sub
				If ((tFindRootPackage = 0) && (pRootPackage '= tPackage)) {
					CONTINUE
				}
			}
			
			// Skip java gateway classes
			CONTINUE:($ZCONVERT(tPackage,"U") = "BEA")
			CONTINUE:($ZCONVERT(tPackage,"U") = "CDR")
			CONTINUE:($ZCONVERT(tPackage,"U") = "COM")
			CONTINUE:($ZCONVERT(tPackage,"U") = "JAVA")
			CONTINUE:($ZCONVERT(tPackage,"U") = "JAVAX")
			CONTINUE:($ZCONVERT(tPackage,"U") = "ORG") 
			CONTINUE:($ZCONVERT(tPackage,"U") = "CA")
			CONTINUE:($ZCONVERT(tPackage,"U") = "WEBLOGIC")
			CONTINUE:($ZCONVERT(tPackage,"U") = "EDU")
			CONTINUE:($ZCONVERT(tPackage,"U") = "COMMONJ")
			
			CONTINUE:($ZCONVERT(tPackage,"U") [ "BEA.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "CDR.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "COM.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "JAVA.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "JAVAX.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "ORG.") 
			CONTINUE:($ZCONVERT(tPackage,"U") [ "CA.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "WEBLOGIC.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "EDU.")
			CONTINUE:($ZCONVERT(tPackage,"U") [ "COMMONJ.")
			
			CONTINUE:((pNamespace '= "%SYS") && (pDatabase = "CACHELIB") && ('..StartsWith(tPackage,"%")))
			
			Set tFound = pList.Find(tPackage,"")
			If ($LENGTH(tFound) = 0) {
				Do pList.Insert(tPackage)
			}
  		}
  		$$$ThrowOnError(tStatus)
		Kill tCall, tStatement, tResultSet
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetCPFMappedPackages(pNamespace As %String, ByRef pList As %ListOfDataTypes) As %Status {
	Set tStatus = $$$OK 
	Try {
		
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
		
		// Assign all mapped packages (query does not includes sub packages)
		Set tCall = "Call Config.MapPackages_List(?)"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set tStatus = tStatement.%Prepare(tCall)
  		$$$ThrowOnError(tStatus)
  		Set tResultSet = tStatement.%Execute(pNamespace)
  		While tResultSet.%Next(.tStatus) {
			$$$ThrowOnError(tStatus)
			
			Set tPackage = tResultSet.%Get("Package")
			Set tDatabase = tResultSet.%Get("Database")
			
			Set tStatus = ..GetLocalDatabasePackages(pNamespace,tDatabase,tPackage,.pList)
			$$$ThrowOnError(tStatus)
			
  		}
  		$$$ThrowOnError(tStatus)
		Kill tCall, tStatement, tResultSet
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetNamespaceMappedPackages(pNamespace As %String, ByRef pList As %ListOfDataTypes) As %Status {
	Set tStatus = $$$OK 
	Try {
	
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
   		
		// Attempt a final grab at all packages mapped at the namespace level from other databases
		Set tQuery = "SELECT Name,Database FROM Config.MapPackages WHERE ((Namespace = '%ALL' OR Namespace = ?) AND SectionHeader = ?)"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set tStatus = tStatement.%Prepare(tQuery)
  		$$$ThrowOnError(tStatus)
  		Set tResultSet = tStatement.%Execute(pNamespace,"MapPackages")
  		While tResultSet.%Next(.tStatus) {
			$$$ThrowOnError(tStatus)
			
			Set tPackage = tResultSet.%Get("Name")
			Set tDatabase = tResultSet.%Get("Database")
			
			Set tStatus = ..GetLocalDatabasePackages(pNamespace,tDatabase,tPackage,.pList)
			$$$ThrowOnError(tStatus)
			
		}
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod CreateGrantStatementFromPackage(pPackageName As %String, pObjectPrivilege As %String = "SELECT", pGrantee As %String, Output pStatus As %Status = {$$$OK}) As %String
{
	Set tGrantStatement = ""
	Try {
		Set tPackageName = $ZCONVERT(pPackageName,"U")
		Set tPackageName = $REPLACE(tPackageName,".","_")	
		
		If (tPackageName [ "USER") {
			Set tPackageName = """" _ tPackageName _ """"
		}
		
		Set tGrantStatement = "GRANT " _ pObjectPrivilege _ " ON SCHEMA " _ tPackageName _ " TO " _ pGrantee
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tGrantStatement
}

/// Append '/' to <var>pPath</var> if it is missing and we are not running on VMS.
ClassMethod fixPath(pPath As %String) As %String
{
	If ""'=pPath {
		If $$$isVMS {
			Quit ##Class(%File).NormalizeDirectory(pPath)
		} ElseIf $$$isUNIX {
			Set pPath = $Translate(pPath,"\","/")
			Quit:("/" '= $E(pPath,*)) pPath_"/"
		} Else {
			Set pPath = $Translate(pPath,"/","\")
			Quit:("\" '= $E(pPath,*)) pPath_"\"
		}
	}
	Quit pPath
}

/// Tests if the given <var>value</var> starts with the given <var>string</var>.
ClassMethod StartsWith(pValue As %String,pString As %String) As %Boolean [ CodeMode = expression, Final ] {
	($E($g(pValue),1,$L($g(pString)))=$g(pString))
}

}
