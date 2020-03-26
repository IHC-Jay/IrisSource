Include EAI.Deploy

Class IHC.EAI.Deployment.UnitTest extends %RegisteredObject {
	
	
	
/// Test the deploy package process
ClassMethod DeployPackage(pLDAPUsername As %String, pLDAPPassword As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set ^EAI.Debug("Deploy",$Username) = "pLDAPUsername=" _ pLDAPUsername _ "|pLDAPPassword=" _ pLDAPPassword
		
		Set tPackage = ..CreatePackage(pLDAPUsername,pLDAPPassword,.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = tPackage.DeployPackage()
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Test the deploy package process
ClassMethod CreatePackage(pLDAPUsername As %String, pLDAPPassword As %String, Output pStatus As %Status = { $$$OK }) As IHC.EAI.Deployment.Package {
	Set tPackage = ""
	Try {
	
		// Get the target production
		Set tStatus = ##class(IHC.EAI.Common.Util).GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set tPackage = ##class(IHC.EAI.Deployment.Package).%New()
		Set tPackage.Name = "Test Deployment"
		Set tPackage.Description = "This is a test deployment to the PROVIDER namespace"
		Set tPackage.Environment = tEnvironment
		Set tPackage.LDAPUsername = pLDAPUsername
		Set tPackage.LDAPPassword = pLDAPPassword
		Set tPackage.Namespace = "PROVIDER"
		
		
		Set tTargetProduction = ..GetTargetProduction("PROVIDER",.pStatus)
		$$$ThrowOnError(pStatus)
		
		// Add actions
		Set tAction = ##class(IHC.EAI.Deployment.Action.File).%New()
		Set tAction.Filename = "Deployment_CLS_TestHL7BusinessProcess.xml"
		Set tAction.ComponentName = "TestHL7BusinessProcess"
		Set tAction.Revision = "4408"
		Set tAction.TargetProduction = tTargetProduction
		Set tAction.CreateRollback = 1
		Set tAction.RollbackFilename = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CLS_TestHL7BusinessProcess_ROLLBACK.xml"
		Set tAction.WhereToLog = "L"
		Set tAction.LogFile = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CLS_TestHL7BusinessProcess.log"
		Set tAction.AllowDeployToSource = 1
		Set tAction.AutoRevert = 0
		Set pStatus = tPackage.ActionList.Insert(tAction)
		$$$ThrowOnError(pStatus)
		
		
		// Add actions
		Set tAction = ##class(IHC.EAI.Deployment.Action.File).%New()
		Set tAction.Filename = "Deployment_CONFIG_TestHL7BusinessProcess.xml"
		Set tAction.ComponentName = "TestHL7BusinessProcess"
		Set tAction.Revision = "4408"
		Set tAction.TargetProduction = tTargetProduction
		Set tAction.CreateRollback = 1
		Set tAction.RollbackFilename = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7BusinessProcess_ROLLBACK.xml"
		Set tAction.WhereToLog = "L"
		Set tAction.LogFile = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7BusinessProcess.log"
		Set tAction.AllowDeployToSource = 1
		Set tAction.AutoRevert = 0
		Set pStatus = tPackage.ActionList.Insert(tAction)
		$$$ThrowOnError(pStatus)
		
		// Add actions
		Set tAction = ##class(IHC.EAI.Deployment.Action.File).%New()
		Set tAction.Filename = "Deployment_CONFIG_TestHL7FileService.xml"
		Set tAction.ComponentName = "TestHL7FileService"
		Set tAction.Revision = "4405"
		Set tAction.TargetProduction = tTargetProduction
		Set tAction.CreateRollback = 1
		Set tAction.RollbackFilename = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7FileService_ROLLBACK.xml"
		Set tAction.WhereToLog = "L"
		Set tAction.LogFile = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7FileService_ROLLBACK.log"
		Set tAction.AllowDeployToSource = 1
		Set tAction.AutoRevert = 0
		Set pStatus = tPackage.ActionList.Insert(tAction)
		$$$ThrowOnError(pStatus)
		
		// Add actions
		Set tAction = ##class(IHC.EAI.Deployment.Action.File).%New()
		Set tAction.Filename = "Deployment_CONFIG_TestHL7FileOperation.xml"
		Set tAction.ComponentName = "TestHL7FileOperation"
		Set tAction.Revision = "4407"
		Set tAction.TargetProduction = tTargetProduction
		Set tAction.CreateRollback = 1
		Set tAction.RollbackFilename = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7FileOperation_ROLLBACK.xml"
		Set tAction.WhereToLog = "L"
		Set tAction.LogFile = $$$USERDEPLOYLOGDIR(tInstanceType,pLDAPUsername) _ "/" _ "Deployment_CONFIG_TestHL7FileOperation.log"
		Set tAction.AllowDeployToSource = 1
		Set tAction.AutoRevert = 0
		Set pStatus = tPackage.ActionList.Insert(tAction)
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tPackage
}

ClassMethod GetTargetProduction(pNamespace As %String, Output pStatus As %Status = { $$$OK }) As %String {
	Set tProduction = ""
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tProduction = ##class(Ens.Director).GetActiveProductionName()
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tProduction
}
}