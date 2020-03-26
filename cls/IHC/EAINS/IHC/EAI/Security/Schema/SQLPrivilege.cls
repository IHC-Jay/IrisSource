Class IHC.EAI.Security.Schema.SQLPrivilege Extends (%RegisteredObject, IHC.EAI.Log.Util, IHC.EAI.Security.Schema.AbstractObject)
{

/// Which namespace owns this privilege
Property Namespace As %String(MAXLEN = 50);

/// Grantee
Property Grantee As %String(MAXLEN = 100);

/// Statement executed to grant privileges
Property GrantStatements As %ListOfDataTypes;

/// Deploy the SQL privileges based on a JSON source file<br/>
/// Do ##class(IHC.EAI.Security.Schema.SQLPrivilege).DeploySQLPrivileges("[DirToInitJSON]")
ClassMethod DeploySQLPrivileges(pDir As %String, pFilename As %String, pEnvironment As %String, pInstanceType As %String, ByRef pLogFile As %File) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ##class(IHC.EAI.Security.Util).CheckPrivileges()
		$$$ThrowOnError(tStatus)
		
		Set tRecordCount = 0
		
		Set tInitFile = ##class(IHC.EAI.Security.Util).fixPath(pDir) _ pFilename
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeploySQLPrivileges","JSON init file: " _ tInitFile) $$$ThrowOnError(tStatus)
		
		If ##class(%File).Exists(tInitFile) {
			Set tFile = ##class(%FileCharacterStream).%New()
			Set tFile.Filename = tInitFile
			
			Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(tFile)
			
			Set tIter = tConsumedJSON.%GetIterator()
			
			While (tIter.%GetNext(.key,.value)) {
				Set tNamespace = value.Namespace
				Set tEnvironments = value.Environment // %Library.Array
				Set tInstanceTypes = value.InstanceType // %Library.Array	
				Set tGrantee = value.Grantee
				Set tGrantStatements = value.GrantStatements	
				Set tEnvironment = 0
				Set tInstanceType = 0
				
				// List of environments
				Set tEnvironmentsList = ##class(%ListOfDataTypes).%New()
				Set tEnvIter = tEnvironments.%GetIterator()
				While (tEnvIter.%GetNext(.tEnvKey,.tEnvValue)) {
					Set:(tEnvValue = pEnvironment) tEnvironment = 1
				}
				
				// List of instance types
				Set tInstanceTypesList = ##class(%ListOfDataTypes).%New()
				Set tInstIter = tInstanceTypes.%GetIterator()
				While (tInstIter.%GetNext(.tInstKey,.tInstValue)) {
					Set:(tInstValue = pInstanceType) tInstanceType = 1
				}
				
				Set tGrntStmtList = ##class(%ListOfDataTypes).%New()
				Set tGrntStmtIter = tGrantStatements.%GetIterator()
				
				While (tGrntStmtIter.%GetNext(.tGrntStmtKey,.tGrntStmtValue)) {
					Do tGrntStmtList.Insert(tGrntStmtValue)
				}
				
				Set tNamespaceExists = ##class(%SYS.Namespace).Exists(tNamespace)
				
				If ((tNamespaceExists) && (tEnvironment) && (tInstanceType)) {
					Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeploySQLPrivileges","Deploying SQL privileges for " _ tGrantee _ " to Namespace: " _ tNamespace) $$$ThrowOnError(tStatus)
					
					If ((pInstanceType '= "MSGBK") || (tNamespace '= "%SYS")) {	// Check mirror status for all but primary
						Set tIsPrimary = ##class(%SYSTEM.Mirror).IsPrimary()
						If (tIsPrimary = 0) {
							Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeploySQLPrivileges","This member is not primary and this namespace (" _ tNamespace _ ") is not '%SYS'. Skipping deployment of SQL privileges.") $$$ThrowOnError(tStatus)
							Quit
						}
					}
					
					Set tStatus = ..DeploySQLPrivilege(tNamespace,tGrantee,tGrntStmtList)
					$$$ThrowOnError(tStatus)
					Set tRecordCount = tRecordCount + 1
				}
			}
		}
		
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeploySQLPrivileges","Record count: " _ tRecordCount) $$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DeploySQLPrivilege(pNamespace As %String, pGrantee As %String, pGrantStatements As %ListOfDataTypes) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tNamespace = pNamespace
		
		// Clear out the existing SQL privileges as a form of reset
		Set tStatus = ..ClearExistingSQLPrivileges(pNamespace,pGrantee)
		$$$ThrowOnError(tStatus)
		
		New $NAMESPACE
   		Set $NAMESPACE = tNamespace
		
		For i=1:1:pGrantStatements.Count() {
			Set tGrantStatement = pGrantStatements.GetAt(i)
			Set tSQL = ##class(%SQL.Statement).%New()
			Set tResultSet = ##class(%SQL.Statement).%ExecDirect(.tSQL,tGrantStatement)
			If ((tResultSet.%SQLCODE) && (tResultSet.%SQLCode '= 100)) {
				Set tSQLCODE = tResultSet.%SQLCODE
				Set tMessage = tResultSet.%Message
				CONTINUE:(tMessage [ "SQLCODE=-428")	// Stored proc doesn't exist for this namespace (possibly not an ENS namespace like %SYS)
				Set tStatus = $$$ERROR($$$GeneralError,"Failed to execute grant statement. (Namespace:" _ $NAMESPACE _ ")" _ " (SQLCODE:" _ tSQLCODE _ ")" _ " (Message:" _ tMessage _ ")")
				$$$ThrowOnError(tStatus)
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ClearExistingSQLPrivileges(pNamespace As %String, pGrantee As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
	
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
		
		Set tGrantee = $REPLACE(pGrantee,"""","")
		
   		Set tDeleteStatement = "DELETE FROM Security.SQLPrivileges WHERE Grantee = '" _ tGrantee _ "' AND Namespace = '" _ pNamespace _ "'"
   		Set tSQL = ##class(%SQL.Statement).%New()
		Set tResultSet = ##class(%SQL.Statement).%ExecDirect(.tSQL,tDeleteStatement)
   		
   		If ((tResultSet.%SQLCODE) && (tResultSet.%SQLCode '= 100)) {
   			Set tStatus = $$$ERROR($$$GeneralError,"Failed to clear existing sql privileges. (Namespace:" _ pNamespace _ ")" _ " (SQLCODE:" _ tResultSet.%SQLCODE _ ")" _ " (Grantee:" _ tGrantee _ ")")
			$$$ThrowOnError(tStatus)
   		}
   		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
