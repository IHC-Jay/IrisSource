Class IHC.EAI.Uptime.Service.Events Extends Ens.BusinessService
{

/// The type of adapter used to communicate with external systems
Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS = "TargetConfigName";

/// Target ConfigName
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.Uptime.Process.Events" ];

Method OnProcessInput(
	pInput As %RegisteredObject,
	Output pOutput As %RegisteredObject) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		If (($SYSTEM.Mirror.IsMember()) & ('$SYSTEM.Mirror.IsPrimary())) {
			$$$LOGINFO("This instance is a mirror member, but not primary.")
		} Else {
			Set tRequest = ##class(IHC.EAI.Uptime.Message.Request).%New()
			Set tRequest.Name = "CheckEnsConfigItems"
			
			// Send Async by default
			Set tStatus = ..SendRequestAsync(..TargetConfigName,tRequest)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()	
	}
	Quit tStatus
}

}