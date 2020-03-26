Class IHC.EAI.Security.Schema.ITFUser Extends (%RegisteredObject, IHC.EAI.Log.Util, IHC.EAI.Security.Schema.Profile)
{

/// Initialize the SQL privileges based on a JSON source file<br/>
/// Do ##class(IHC.EAI.Security.Schema.ITFUser).Init("[DirToInitJSON]")
ClassMethod DeployITFUsers(pDir As %String, pFilename As %String, pEnvironment As %String, pInstanceType As %String, ByRef pLogFile As %File) As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set tRecordCount = 0
		
		Set tInitFile = ##class(IHC.EAI.Security.Util).fixPath(pDir) _ pFilename
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployITFUsers","JSON init file: " _ tInitFile) $$$ThrowOnError(tStatus)
		
		If ##class(%File).Exists(tInitFile) {
			Set tFile = ##class(%FileCharacterStream).%New()
			Set tFile.Filename = tInitFile
			Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(tFile)
			
			Set tIter = tConsumedJSON.%GetIterator()
			
			While (tIter.%GetNext(.key,.value)) {
				Set tName= value.Name
				Set tDescription= value.Description
				Set tEnvironments = value.Environment // %Library.Array
				Set tInstanceTypes = value.InstanceType // %Library.Array	
				Set tGrantedRoles = value.GrantedRoles // %Library.Array
				Set tGrantedSystemResources = value.GrantedSystemResources // %Library.Array	
				Set tGrantedITFResources = value.GrantedITFResources // %Library.Array	
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
				
				// List of granted roles
				Set tGrantedRolesList = ##class(%ListOfDataTypes).%New()
				Set tGrRolesIter = tGrantedRoles.%GetIterator()
				While (tGrRolesIter.%GetNext(.tGrRolesKey,.tGrRolesValue)) {
					Do tGrantedRolesList.Insert(tGrRolesValue)	
				}
				
				If ((tEnvironment) && (tInstanceType)) {
					// Update user
					Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployITFUsers","Deploying ITF user: " _ tName) $$$ThrowOnError(tStatus)
					Set tStatus = ..DeployITFUser()
					$$$ThrowOnError(tStatus)
				}

				Set tRecordCount = tRecordCount + 1
			}
		}
		
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployITFUsers","Record count: " _ tRecordCount) $$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DeployITFUser() As %Status {
	Quit $$$OK
}

}
