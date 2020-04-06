Class IHC.EAI.KPI.Service.Metrics Extends Ens.BusinessService
{

Parameter SETTINGS = "MetricsOperation";

Property MetricsOperation As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.KPI.Operation.Metrics" ];

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		If (($SYSTEM.Mirror.IsMember()) & ('$SYSTEM.Mirror.IsPrimary())) {
			$$$LOGINFO("This instance is a mirror member, but not primary.")
		} Else {
			Set tStatus = ..SendRequestSync(..MetricsOperation,pInput,.pOutput)
			$$$ThrowOnError(tStatus)
		}
				
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
