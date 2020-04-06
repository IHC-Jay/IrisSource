Include EAI.Deploy

Class IHC.EAI.Deployment.Package extends %RegisteredObject {

	Property Name As %String;

	Property Description As %String;

	Property Environment As %String(VALUELIST = ",DEV,QA,UAT,PROD");

	Property LDAPUsername As %String;

	Property LDAPPassword As %String;

	Property Namespace As %String(VALUELIST = ",ADT,ADT_IN,BILLING,DEMOGRAPHICS,LAB,MISC,ORDERS,RESULTS,PAYER,PROVIDER");

	Property ActionList As list of IHC.EAI.Deployment.Action;


Method Deploy() As %Status {

	Set tStatus = $$$OK
	Try {
		
		// Validate properties
			// Strip trailing-leading whitespace from any potential user input, for example
		
		// Setup SVN
		Set tStatus = ##class(IHC.EAI.Deployment.Util).SetupSVN(..LDAPUsername,..LDAPPassword)
		$$$ThrowOnError(tStatus)
		
		// Execute actions
		For i=1:1:..ActionList.Count() {
			Set tAction = ..ActionList.GetAt(i)
			If (tAction.%IsA("IHC.EAI.Deployment.Action.File")) {
				Set tStatus = ..DeployFile(tAction,..LDAPUsername,..LDAPPassword,..Environment,..Namespace)
				$$$ThrowOnError(tStatus)
			}
			
			/*If (tAction.%IsA("IHC.EAI.Deployment.Action.SSL")) {
				Set tStatus = ..DeploySSLConfig(tAction,..SVNUsername,..SVNPassword,..Environment)
				$$$ThrowOnError(tStatus)
			}
			
			If (tAction.%IsA("IHC.EAI.Deployment.Action.EnsTask")) {
				Set tStatus = ..DeployEnsTask(tAction,..SVNUsername,..SVNPassword,..Environment)
				$$$ThrowOnError(tStatus)
			}
			
			If (tAction.%IsA("IHC.EAI.Deployment.Action.EnsCredentials")) {
				Set tStatus = ..DeployEnsCredentials(tAction,..SVNUsername,..SVNPassword,..Environment)
				$$$ThrowOnError(tStatus)
			}*/
		}
		
		
		// 
		
	
	} Catch eException {
		Set tStatus = eException.AsStatus()
	 	Set tErrorMessage = $System.Status.GetErrorText(tStatus)
	 	Do ##class(IHC.EAI.Deployment.Util).Log($Username,"DeployFile ERROR: " _ tErrorMessage)
	}
	Quit tStatus
}

ClassMethod DeployFile(pFile As IHC.EAI.Deployment.Action.File, pLDAPUsername As %String, pLDAPPassword As %String, pEnvironment As %String, pNamespace As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		// @@LOG to debug global
		
		// Validate properties
			// Strip trailing-leading whitespace from any potential user input, for example
			// Are we deploying to the correct environment/namespace?
		
		Set tComponentName = $ZSTRIP(pFile.ComponentName, "<>W")
		
		// Checkout file
		Set tStatus = ##class(IHC.EAI.Deployment.Util).CheckoutFile(pFile.Filename,pLDAPUsername,pLDAPPassword,pFile.Revision)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(IHC.EAI.Deployment.Util).DeployCode(pLDAPUsername,pNamespace,pFile.Filename,pFile.TargetProduction,pFile.CreateRollback,pFile.RollbackFilename,pFile.LogFile,pLDAPUsername)
		$$$ThrowOnError(tStatus)
		
		// pFilename As %String, pUsername As %String, pNamespace As %String, pComponentName As %String, pRevision As %String, pEnvironment As %String
		Set tStatus = ##class(IHC.EAI.Deployment.Util).UpdateDeploymentHistory(pFile.Filename,pLDAPUsername,pNamespace,tComponentName,pFile.Revision,pEnvironment)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	 	Set tErrorMessage = $System.Status.GetErrorText(tStatus)
	 	Do ##class(IHC.EAI.Deployment.Util).Log($Username,"DeployFile ERROR: " _ tErrorMessage)
	}
	Quit tStatus
}

}