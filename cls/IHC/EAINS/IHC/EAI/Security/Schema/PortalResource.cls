Class IHC.EAI.Security.Schema.PortalResource Extends (%RegisteredObject, IHC.EAI.Log.Util, IHC.EAI.Security.Schema.AbstractObject)
{

/// The management portal page reference
Property Page As %String(MAXLEN = 250);

/// The custom ITF Resource assigned to this page<br/>
/// Maps to IHC.ITF.Security.Type.ITFResource Name property,</br>
/// as that is the IdKey of the resource object.
Property ITFResource As IHC.EAI.Security.Schema.Resource;

/// Initialize the ITF resources based on a JSON source file<br/>
/// Do ##class(IHC.EAI.Security.Schema.PortalResource).Init("[DirToInitJSON]")
ClassMethod DeployPortalResourceAssignments(pDir As %String, pFilename As %String, pEnvironment As %String, pInstanceType As %String, ByRef pLogFile As %File) As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set tRecordCount = 0
		
		Set tInitFile = ##class(IHC.EAI.Security.Util).fixPath(pDir) _ pFilename
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployPortalResourceAssignments","JSON init file: " _ tInitFile) $$$ThrowOnError(tStatus)
		
		If ##class(%File).Exists(tInitFile) {
			Set tFile = ##class(%FileCharacterStream).%New()
			Set tFile.Filename = tInitFile
			
			Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(tFile)
			
			Set tIter = tConsumedJSON.%GetIterator()
			
			While (tIter.%GetNext(.key,.value)) {
				Set tPage = value.Page
				Set tITFResource = value.ITFResource
				Set tEnvironments = value.Environment // %Library.Array
				Set tInstanceTypes = value.InstanceType // %Library.Array		
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
					// Update Portal Resource
					Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployPortalResourceAssignments","Deploying portal resource assignment for page: " _ tPage) $$$ThrowOnError(tStatus)
					Set tStatus = ..DeployPortalResourceAssignment(tPage,tITFResource)
					$$$ThrowOnError(tStatus)
	
					Set tRecordCount = tRecordCount + 1
				}
			}
		}
		
		Set tStatus = ..Log(.pLogFile,..%ClassName(1),"DeployPortalResourceAssignments","Record count: " _ tRecordCount) $$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DeployPortalResourceAssignment(pPage As %String, pITFResource As %String) As %Status {
	Set tStatus = $$$OK
	Try {
	
		Set tPage = pPage
		Set tITFResource = pITFResource
		
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
   		
		Set tStatus = ##class(%SYS.Portal.Resources).%SetCustomResource(tPage,tITFResource)
		$$$ThrowOnError(tStatus)
	
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
