Include EAI.Common

Class IHC.EAI.Common.Util Extends %RegisteredObject
{

/// Get the current environment (DEV/QA/UAT/PROD) and<br/>
/// instance type (CLIN/PAYER/PROVIDER/MSGBK/SANDBOX) and<br/>
/// instance name
ClassMethod GetEnvironment(Output pEnvironment As %String, Output pInstanceType As %String, Output pInstanceName As %String) As %Status
{
	Set tStatus = $$$OK
	Set pEnvironment = "", pInstanceType = ""
	Try {
		Set pInstanceName = $ZCONVERT(##class(%SYS.System).GetInstanceName(),"U")
		If (pInstanceName [ "DEV") {
			Set pEnvironment = $$$EnvironmentType1
		} ElseIf (pInstanceName [ "QA") {
			Set pEnvironment = $$$EnvironmentType2
		} ElseIf (pInstanceName [ "UAT") {
			Set pEnvironment = $$$EnvironmentType3
		} ElseIf ((pInstanceName [ "PRD") || (pInstanceName [ "PROD")) {
			Set pEnvironment = $$$EnvironmentType4
		}  ElseIf (pInstanceName [ "SAND") {
			Set pEnvironment = $$$EnvironmentType5
		} Else {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Unknown environment: " _ pInstanceName))
		}
		
		If (pInstanceName [ "CLIN") {
			Set pInstanceType = $$$InstanceType1
		} ElseIf (pInstanceName [ "PAYER") {
			Set pInstanceType = $$$InstanceType2
		} ElseIf (pInstanceName [ "PROVIDER") {
			Set pInstanceType = $$$InstanceType3
		} ElseIf (pInstanceName [ "MSGBK") {
			Set pInstanceType = $$$InstanceType4
		} ElseIf (pInstanceName [ "SAND") {
			Set pInstanceType = $$$InstanceType5
		}  Else {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Unknown instance type: " _ pInstanceName))
		}
		
	} Catch eException {
		Set tStatus  = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod WriteDebug(pLine As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tUser = $USERNAME
		Set tTimeStamp = $ZDT($H,3)
		Set tIndex = 0
		
		Set tExists = $GET(^EAI.Debug(tUser,tTimeStamp,tIndex))
		While (tExists '= "") {
			Set tIndex = tIndex + 1
			Set tExists = $GET(^EAI.Debug(tUser,tTimeStamp,tIndex))
		}
		
		Set ^EAI.Debug(tUser,tTimeStamp,tIndex) = pLine
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
