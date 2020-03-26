Class IHC.EAI.KPI.Util.Installer Extends IHC.EAI.Common.Util
{

/// Do ##class(IHC.EAI.KPI.Util.Installer).Install()
ClassMethod Install() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		If ($NAMESPACE '= "EAI") {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Must run this in EAI namespace!"))	
		}
		
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(IHC.EAI.System.Data.Instance).Init(1)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(IHC.EAI.System.Data.Namespace).Init(1)
		$$$ThrowOnError(tStatus)
		
		// Configure ITF_Services user
		Set tStatus = ..ConfigureITFServicesUser()
		$$$ThrowOnError(tStatus)
		
		// Configure ITF_Services Ensemble credentials
		Set tStatus = ##class(Ens.Config.Credentials).SetCredential("ITF_Services","ITF_Services","ITF_Services",1)
		$$$ThrowOnError(tStatus)
		
		If (tInstanceType = "MSGBK") {
			// Run server-side setups
			Set tStatus = ##class(IHC.EAI.KPI.Schema.Application).Init(1)
			$$$ThrowOnError(tStatus)
			
		} Else {
			// Run interface-side setups	
			
			// Server info
			Set SQLCODE = "", tPhysicalHost = "", tPhysicalPort = ""
			&sql(SELECT PhysicalHost,PhysicalPort INTO :tPhysicalHost,:tPhysicalPort FROM IHC_EAI_System_Data.Instance WHERE EnvironmentType = :tEnvironment AND NodeType = 'SERVER')
			If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed find server entry for environment type: " _ tEnvironment))	
			}
			
			Set ^EAI.Setting("ServerNodeHost") = tPhysicalHost
			Set ^EAI.Setting("ServerNodePort") = tPhysicalPort
			
			// Create/update tasks
			Set tStatus = ..ConfigureInterfaceTasks()
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ConfigureITFServicesUser() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Security is setup in %SYS namespace
		New $NAMESPACE
   		Set $NAMESPACE = "%SYS"
		
		// Create the default services role
		// Check if exists
		Set tExists = ##class(Security.Roles).Exists("ITF-WebServices")
		If ('tExists) {		
			// Just create the role
			Set tGrantedResources = "%DB_%DEFAULT:RW,%DB_CACHETEMP:RW,%DB_EAI:RW,%DB_CACHESYS:R"
			Set tStatus = ##class(Security.Roles).Create("ITF-WebServices","EAI web services role",tGrantedResources)
			$$$ThrowOnError(tStatus)
			
		}
		
		// Create the default user
		// Check if exists
		Set tExists = ##class(Security.Users).Exists("ITF_Services")
		If ('tExists) {
			// Create
			Set tStatus = ##class(Security.Users).Create("ITF_Services","ITF-WebServices","ITF_Services","ITF Web Services user","EAI","","",0,1,"",,,,,1,1)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	
	Quit tStatus
}

ClassMethod ConfigureInterfaceTasks() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// If doesn't already exist, create KPI TC
		
		Set tTask = ##class(%SYS.Task).%New()
		Set tTask.Name = "EAI KPI - Transaction Count"
		Set tTask.TaskClass = "IHC.EAI.KPI.Task.CreateKPISnapshot"
		Set tTask.Description = "Daily transaction count KPI measurements"
		Set tTask.NameSpace = "EAI"
		Set tTaskDef = ##class(IHC.EAI.KPI.Task.CreateKPISnapshot).%New()
		Set tTaskDef.KPIController = "IHC.EAI.KPI.Controller.TransactionCount"
		Set tStatus = tTask.AssignSettings(tTaskDef)
		$$$ThrowOnError(tStatus)
		
		// If doesn't already exist, create KPI CC
		
		Set tTask = ##class(%SYS.Task).%New()
		Set tTask.Name = "EAI KPI - Component Count"
		Set tTask.TaskClass = "IHC.EAI.KPI.Task.CreateKPISnapshot"
		Set tTask.Description = "Daily component count KPI measurements"
		Set tTask.NameSpace = "EAI"
		Set tTaskDef = ##class(IHC.EAI.KPI.Task.CreateKPISnapshot).%New()
		Set tTaskDef.KPIController = "IHC.EAI.KPI.Controller.ComponentCount"
		Set tStatus = tTask.AssignSettings(tTaskDef)
		$$$ThrowOnError(tStatus)
		
		
		
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
