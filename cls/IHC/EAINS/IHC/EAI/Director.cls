Include Ensemble

Class IHC.EAI.Director Extends %RegisteredObject
{

/// ##class(IHC.EAI.Director).StopAll()
ClassMethod StopAll(pForce As %Boolean = 1) As %Status [ Internal ]
{
	#Dim tList As %ListOfDataTypes
	
	Set tStatus = $$$OK
	
	Try {
		
		Set tList = ..GetProductionList("",.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ""
		For i=1:1:tList.Count()  {
			Set tNamespace = tList.GetAt(i)
			
			Set tStatus = ..StopProduction(tNamespace,30,.tInitialState,.tState,1)
			$$$ThrowOnError(tStatus)
		}
	} Catch eException {
		Set tStatus=eException.AsStatus()
	}
	Quit tStatus
}

/// Get the list of production names
ClassMethod GetProductionList(pOrder As %String, Output pStatus As %Status = {$$$OK}) As %ListOfDataTypes
{
	Try {
	
		Set tProductionList = ##class(%ListOfDataTypes).%New()
		
		Set tNamespace = ""
		For {
			Set tNamespace = $ORDER(^%SYS("Ensemble","RunningNamespace",tNamespace))
			Quit:tNamespace=""
			
			Set tStatus = tProductionList.Insert(tNamespace)
			$$$ThrowOnError(tStatus)
		}
	} Catch eException {
		Set pStatus = eException.AsStatus()	
	}
	Quit tProductionList
}

/// Try to stop the Production in pNamespace (if not already stopped)
///  (we assume only one Production per namespace !)
/// Result can be:
///   failure, returns %Status
///   success, returns
///      pState=1 ($$$eProductionStateRunning)
///      pState=2 ($$$eProductionStateStopped)
///      pState=3 ($$$eProductionStateSuspended)
///      pState=4 ($$$eProductionStateTroubled)
///      pState=5 ($$$eProductionStateNetworkStopped) 
ClassMethod StopProduction(pNamespace As %String, pTimeout As %Numeric = 30, ByRef pInitialState As %Integer, ByRef pState As %Integer, pForce As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
 	
 	Try {
	 	
 		New $NAMESPACE
 		Set $NAMESPACE = pNamespace
 		
 		Set (pInitialState,pState) = 0
 		
 		Set tStatus = ##class(Ens.Director).GetProductionStatus(.tProductionName,.pInitialState)
 		$$$ThrowOnError(tStatus)
		
		If (pInitialState '= $$$eProductionStateRunning) {
			Set pState = $$$eProductionStateStopped
			Quit
		}
 		
 		Set tStatus = ##class(Ens.Director).StopProduction(pTimeout,pForce)
 		$$$ThrowOnError(tStatus)
 		
 		Set tStatus = ##class(Ens.Director).GetProductionStatus(.tProductionName,.pState)
 		$$$ThrowOnError(tStatus)
 		
 	} Catch eException {
	 	Set tStatus = eException.AsStatus()
 	}
 	Quit tStatus
}

/// Try to start pProduction in pNamespace (if it is stopped)
/// Result can be:
///   failure, returns %Status
///   success, returns
///      pState=1 ($$$eProductionStateRunning)
///      pState=2 ($$$eProductionStateStopped)
///      pState=3 ($$$eProductionStateSuspended)
///      pState=4 ($$$eProductionStateTroubled)
///      pState=5 ($$$eProductionStateNetworkStopped) 
ClassMethod StartProduction(pNamespace As %String, pProductionName, ByRef pState As %Integer) As %Status
{
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
 		Set $NAMESPACE = pNamespace
 		
		// Get current status
		Set tStatus = ##class(Ens.Director).GetProductionStatus(.tProductionName,.pState)
		$$$ThrowOnError(tStatus)
		
		Quit:(pState '= $$$eProductionStateStopped)
		
		If ($GET(pProductionName) = "") {
			Set pProductionName = ##class(HS.Util.Installer.ConfigItem).GetPropertyValue(pNamespace,"Production",.tStatus)
			$$$ThrowOnError(tStatus)
		}
		
		Set tDisabled=##class(HS.Util.Installer.ConfigItem).GetPropertyValue(pNamespace,"Disabled",.tStatus)
		$$$ThrowOnError(tStatus)
		
		If (tDisabled) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Production is disabled"))
		}
		
		// Try to start it
		Set tStatus = ##class(Ens.Director).StartProduction(pProductionName)
		$$$ThrowOnError(tStatus)
		
		// Check if it started
		Set tStatus = ##class(Ens.Director).GetProductionStatus(.tProductionName,.pState)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
	 	Set tStatus = eException.AsStatus()
 	}
 	Quit tStatus
}

}
