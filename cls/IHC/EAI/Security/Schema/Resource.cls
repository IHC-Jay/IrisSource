Class IHC.EAI.Security.Schema.Resource Extends (%RegisteredObject, IHC.EAI.Log.Util, IHC.EAI.Security.Schema.AbstractObject)
{

/// The name of this Resource
Property Name As %String(MAXLEN = 100);

/// A short description of this Resource
Property Description As %String(MAXLEN = 250);

/// The set of public permissions for this resource<br/>
/// Any combination of the following values are acceptable:<br/>
/// 	"R", "W", and "U"
Property Permission As %String(MAXLEN = 3);

/// Deploy the ITF and System resources based on a JSON source file<br/>
/// Do ##class(IHC.EAI.Security.Schema.Resource).DeployResources("[DirToInitJSON]")<br/>
/// or Do ##class(IHC.EAI.Security.Schema.SystemResource).DeployResources("[DirToInitJSON]")
ClassMethod DeployResources(pDir As %String, pFilename As %String, pEnvironment As %String, pInstanceType As %String, ByRef pLogFile As %File) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ##class(IHC.EAI.Security.Util).CheckPrivileges()
		$$$ThrowOnError(tStatus)
		
		Set tRecordCount = 0
		
		Set tInitFile = ##class(IHC.EAI.Security.Util).fixPath(pDir) _ pFilename
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployResources","JSON init file: " _ tInitFile) $$$ThrowOnError(tStatus)
		
		If ##class(%File).Exists(tInitFile) {
			Set tFile = ##class(%FileCharacterStream).%New()
			Set tFile.Filename = tInitFile
			
			Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(tFile)
			
			Set tIter = tConsumedJSON.%GetIterator()
			
			While (tIter.%GetNext(.key,.value)) {
				Set tName = value.Name
				Set tDescription = value.Description
				Set tEnvironments = value.Environment // %Library.Array
				Set tInstanceTypes = value.InstanceType // %Library.Array	
				Set tPermission = value.Permission	
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
				
				If ((tEnvironment) && (tInstanceType)) {
					// Deploy the resource
					Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployResources","Deploying resource: " _ tName) $$$ThrowOnError(tStatus)
					Set tStatus = ..DeployResource(tName,tDescription,tPermission)
					$$$ThrowOnError(tStatus)
					Set tRecordCount = tRecordCount + 1
				}
			}
		}
		
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployResources","Record count: " _ tRecordCount) $$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DeployResource(pName As %String, pDescription As %String, pPermission As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
		
		Set tName = pName
		Set tDescription = pDescription
		Set tPublicPermission = pPermission
		
		// Check if exists
		Set tExists = ##class(Security.Resources).Exists(tName)
		If (tExists) {
			If ($ZCONVERT(tName,"U") = "ITF_ADMIN") {
				Set tStatus = ##class(Security.Resources).Delete("ITF_ADMIN")
				$$$ThrowOnError(tStatus)
				
				Set tStatus = ##class(Security.Resources).Create(tName,tDescription,tPublicPermission)
				$$$ThrowOnError(tStatus)	
			} Else {
				Set tProperties("Description") = tDescription
				Set tProperties("PublicPermission") = tPublicPermission
				Set tStatus = ##class(Security.Resources).Modify(tName,.tProperties)
				$$$ThrowOnError(tStatus)
			}
		} Else {
			Set tStatus = ##class(Security.Resources).Create(tName,tDescription,tPublicPermission)
			$$$ThrowOnError(tStatus)	
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
