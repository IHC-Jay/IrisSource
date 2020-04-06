Class IHC.EAI.Monitor.Mirror.Service Extends Ens.BusinessService
{

/// The type of adapter used to communicate with external systems
Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS = "TargetConfigName,StatusServiceURL";

/// Target ConfigName
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.Monitor.Mirror.Process" ];

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tRequest = ##class(IHC.EAI.Monitor.Message.Request).%New()
		Set tRequest.Name = "MirrorStatus"
		
		// Send Async by default
		Set tStatus = ..SendRequestAsync(..TargetConfigName,tRequest)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()	
	}
	Quit tStatus
}

}
